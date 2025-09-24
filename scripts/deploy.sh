#!/bin/bash

# Script de despliegue para producción
# Uso: ./scripts/deploy.sh [production|staging]

set -e

# Configuración de la aplicación base
BASE_APP_NAME="sboil"

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

# Configuración
ENVIRONMENT=${1:-"production"}
BACKUP_DIR="backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

log_info "Iniciando despliegue para entorno: $ENVIRONMENT"

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

# Crear directorio de backups si no existe
mkdir -p $BACKUP_DIR

# Crear backup antes del despliegue
log_info "Creando backup pre-despliegue..."
tar -czf "$BACKUP_DIR/pre-deploy-$TIMESTAMP.tar.gz" \
    app/ docker/ \
    --exclude=app/node_modules \
    --exclude=app/vendor \
    --exclude=app/storage/logs/* \
    --exclude=app/storage/framework/cache/* \
    --exclude=app/storage/framework/sessions/* \
    --exclude=app/storage/framework/views/*

log_success "Backup creado: $BACKUP_DIR/pre-deploy-$TIMESTAMP.tar.gz"

# Configurar variables de entorno según el ambiente
if [ "$ENVIRONMENT" = "production" ]; then
    log_info "Configurando entorno de producción..."
    if [ -f "./env.production" ]; then
        cp ./env.production ./app/.env
        log_success "Archivo .env de producción aplicado"
    else
        log_warning "Archivo env.production no encontrado, usando .env actual"
    fi
elif [ "$ENVIRONMENT" = "staging" ]; then
    log_info "Configurando entorno de staging..."
    if [ -f "./env.staging" ]; then
        cp ./env.staging ./app/.env
        log_success "Archivo .env de staging aplicado"
    else
        log_warning "Archivo env.staging no encontrado, usando .env actual"
    fi
fi

# Detener contenedores actuales
log_info "Deteniendo contenedores actuales..."
docker-compose down

# Construir nuevas imágenes
log_info "Construyendo nuevas imágenes..."
docker-compose build --no-cache

# Iniciar contenedores
log_info "Iniciando contenedores..."
docker-compose up -d

# Esperar a que los contenedores estén listos
log_info "Esperando a que los contenedores estén listos..."
sleep 20

# Verificar que los contenedores estén ejecutándose
if ! docker-compose ps | grep -q "Up"; then
    log_error "Los contenedores no se iniciaron correctamente"
    exit 1
fi

# Instalar/actualizar dependencias de PHP
log_info "Instalando dependencias de PHP..."
docker-compose exec -T php composer install --no-dev --optimize-autoloader

# Instalar/actualizar dependencias de Node
log_info "Instalando dependencias de Node..."
docker-compose exec -T node npm ci

# Ejecutar migraciones
log_info "Ejecutando migraciones de base de datos..."
docker-compose exec -T php php artisan migrate --force

# Compilar assets para producción
log_info "Compilando assets para producción..."
docker-compose exec -T node npm run build

# Optimizar aplicación
log_info "Optimizando aplicación..."
docker-compose exec -T php php artisan config:cache
docker-compose exec -T php php artisan route:cache
docker-compose exec -T php php artisan view:cache
docker-compose exec -T php php artisan event:cache

# Limpiar cachés antiguos
log_info "Limpiando cachés..."
docker-compose exec -T php php artisan queue:restart

# Configurar permisos
log_info "Configurando permisos..."
docker-compose exec -T php chown -R www:www /var/www/html/storage
docker-compose exec -T php chown -R www:www /var/www/html/bootstrap/cache

# Verificar el estado de la aplicación
log_info "Verificando estado de la aplicación..."
sleep 5

# Test básico de conectividad
if curl -f -s http://localhost > /dev/null; then
    log_success "Aplicación web responde correctamente"
else
    log_error "La aplicación web no responde"
fi

# Test de WebSockets
if curl -f -s http://localhost:8080 > /dev/null; then
    log_success "Servidor WebSocket responde correctamente"
else
    log_warning "El servidor WebSocket no responde (esto puede ser normal)"
fi

# Mostrar logs recientes para verificar errores
log_info "Logs recientes de la aplicación:"
docker-compose logs --tail=20 php

# Crear backup post-despliegue
log_info "Creando backup post-despliegue..."
tar -czf "$BACKUP_DIR/post-deploy-$TIMESTAMP.tar.gz" \
    app/ docker/ \
    --exclude=app/node_modules \
    --exclude=app/vendor \
    --exclude=app/storage/logs/* \
    --exclude=app/storage/framework/cache/* \
    --exclude=app/storage/framework/sessions/* \
    --exclude=app/storage/framework/views/*

log_success "Backup post-despliegue creado: $BACKUP_DIR/post-deploy-$TIMESTAMP.tar.gz"

# Resumen del despliegue
echo ""
log_success "¡Despliegue completado exitosamente!"
echo ""
log_info "Información del despliegue:"
echo -e "  ${GREEN}Entorno:${NC} $ENVIRONMENT"
echo -e "  ${GREEN}Timestamp:${NC} $TIMESTAMP"
echo -e "  ${GREEN}Aplicación web:${NC} http://localhost"
echo -e "  ${GREEN}WebSockets:${NC} ws://localhost:8080"
echo ""
log_info "Backups creados:"
echo "  - Pre-despliegue: $BACKUP_DIR/pre-deploy-$TIMESTAMP.tar.gz"
echo "  - Post-despliegue: $BACKUP_DIR/post-deploy-$TIMESTAMP.tar.gz"
echo ""
log_info "Comandos útiles post-despliegue:"
echo "  make logs          - Ver logs en tiempo real"
echo "  make status        - Ver estado de contenedores"
echo "  make shell         - Acceder al contenedor PHP"
echo ""

# Verificación final
log_info "Ejecutando verificación final..."
docker-compose ps
echo ""
log_success "¡Despliegue finalizado correctamente!"
