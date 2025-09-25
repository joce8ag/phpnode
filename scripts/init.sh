#!/bin/bash

# Script de inicialización para nueva aplicación Laravel
# Uso: ./scripts/init.sh [nombre_aplicacion]

set -e

# Configuración de la aplicación base
# Leer el nombre desde .app-config si existe
if [ -f ".app-config" ]; then
    source .app-config
    BASE_APP_NAME=$APP_NAME
else
    BASE_APP_NAME="sboil"
fi

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funciones
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar si se proporcionó nombre de aplicación
APP_NAME=${1:-"$BASE_APP_NAME"}

log_info "Inicializando aplicación Laravel: $APP_NAME"

# Verificar que Docker esté ejecutándose
if ! docker info > /dev/null 2>&1; then
    log_error "Docker no está ejecutándose. Por favor, inicia Docker y vuelve a intentar."
    exit 1
fi

# Verificar que la red externa existe
if ! docker network ls | grep -q "red_general"; then
    log_error "La red 'red_general' no existe. Por favor, créala antes de continuar:"
    log_info "docker network create red_general"
    exit 1
else
    log_success "Red 'red_general' encontrada correctamente"
fi

# Crear directorio de aplicación si no existe
if [ ! -d "./app" ]; then
    log_info "Creando directorio de aplicación..."
    mkdir -p app
fi

# Actualizar .app-config con el nombre de la aplicación si es diferente
if [ "$APP_NAME" != "$BASE_APP_NAME" ]; then
    log_info "Actualizando nombre de aplicación a: $APP_NAME"
    sed -i.bak "s/APP_NAME=${BASE_APP_NAME}/APP_NAME=${APP_NAME}/g" .app-config
    rm .app-config.bak
fi

# Construir imágenes
log_info "Construyendo imágenes Docker..."
docker-compose build

# Iniciar contenedores
log_info "Iniciando contenedores..."
docker-compose up -d

# Esperar a que los contenedores estén listos
log_info "Esperando a que los contenedores estén listos..."
sleep 15

# Verificar si Laravel ya está instalado
if [ ! -f "./app/artisan" ]; then
    log_info "Instalando Laravel..."
    docker-compose exec php composer create-project laravel/laravel . --remove-vcs
    log_success "Laravel instalado correctamente"
else
    log_warning "Laravel ya está instalado, omitiendo instalación"
fi

# Configurar .env
log_info "Configurando archivo .env..."
if [ ! -f "./app/.env" ]; then
    if [ -f "./env.example" ]; then
        cp ./env.example ./app/.env
    else
        docker-compose exec php cp .env.example .env
    fi
fi

# Generar APP_KEY
log_info "Generando APP_KEY..."
docker-compose exec php php artisan key:generate

# Instalar Laravel Reverb
log_info "Instalando Laravel Reverb..."
docker-compose exec php composer require laravel/reverb
docker-compose exec php php artisan reverb:install --no-interaction

# Instalar dependencias npm
log_info "Instalando dependencias npm..."
docker-compose exec node npm install

# Configurar permisos
log_info "Configurando permisos..."
docker-compose exec php chown -R www:www /var/www/html/storage
docker-compose exec php chown -R www:www /var/www/html/bootstrap/cache

# Reiniciar contenedores para aplicar cambios
log_info "Reiniciando contenedores..."
docker-compose restart

log_success "¡Aplicación $APP_NAME inicializada correctamente!"
echo ""
log_info "Información de acceso:"
echo -e "  ${GREEN}Aplicación web:${NC} http://localhost"
echo -e "  ${GREEN}WebSockets:${NC} ws://localhost:8080"
echo -e "  ${GREEN}Vite dev server:${NC} http://localhost:5173"
echo -e "  ${GREEN}Redis:${NC} localhost:6379"
echo ""
log_info "Comandos útiles:"
echo "  make logs          - Ver logs en tiempo real"
echo "  make shell         - Acceder al contenedor PHP"
echo "  make npm-dev       - Iniciar servidor de desarrollo Vite"
echo "  make artisan cmd=\"migrate\" - Ejecutar comandos artisan"
echo ""
log_success "¡La aplicación está lista para el desarrollo!"
