#!/bin/bash

# Script para copiar plantilla a nueva aplicación
# Uso: ./scripts/copy-template.sh <nombre_nueva_aplicacion> [directorio_destino]

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

# Obtener nombre de la aplicación
if [ $# -lt 1 ]; then
    echo ""
    log_info "=== Creador de Nueva Aplicación ==="
    echo ""
    read -p "🚀 Nombre de la nueva aplicación: " NEW_APP_NAME

    if [ -z "$NEW_APP_NAME" ]; then
        log_error "El nombre de la aplicación no puede estar vacío"
        exit 1
    fi

    echo ""
    read -p "📁 Directorio destino (presiona Enter para '../'): " DEST_DIR
    DEST_DIR=${DEST_DIR:-"../"}
else
    NEW_APP_NAME=$1
    DEST_DIR=${2:-"../"}
fi

# Validar nombre de aplicación
if [[ ! $NEW_APP_NAME =~ ^[a-zA-Z0-9_-]+$ ]]; then
    log_error "El nombre de la aplicación solo puede contener letras, números, guiones y guiones bajos"
    exit 1
fi

CURRENT_DIR=$(pwd)
NEW_APP_DIR="$DEST_DIR/$NEW_APP_NAME"

log_info "Copiando plantilla a nueva aplicación: $NEW_APP_NAME"
log_info "Directorio destino: $NEW_APP_DIR"

# Verificar que no existe el directorio destino
if [ -d "$NEW_APP_DIR" ]; then
    echo ""
    log_warning "⚠️  El directorio '$NEW_APP_DIR' ya existe"
    echo ""
    echo "Contenido actual:"
    ls -la "$NEW_APP_DIR" | head -5
    echo ""
    read -p "❌ ¿Deseas ELIMINAR todo el contenido y continuar? [y/N]: " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "✅ Operación cancelada por el usuario"
        exit 1
    fi

    echo ""
    log_warning "🗑️  Eliminando directorio existente..."
    rm -rf "$NEW_APP_DIR"
    log_success "✅ Directorio eliminado correctamente"
fi

# Crear directorio base
echo ""
log_info "📁 Creando estructura de directorios..."
mkdir -p "$NEW_APP_DIR"

# Copiar archivos y directorios necesarios (excluyendo app/ y backups/)
echo ""
log_info "📋 Copiando archivos de plantilla..."
echo ""

log_info "   🐳 Copiando configuración Docker..."
cp -r docker/ "$NEW_APP_DIR/"

log_info "   🔧 Copiando docker-compose.yml..."
cp docker-compose.yml "$NEW_APP_DIR/"

log_info "   ⚙️  Copiando Makefile..."
cp Makefile "$NEW_APP_DIR/"

log_info "   📜 Copiando scripts..."
cp -r scripts/ "$NEW_APP_DIR/"

# No se copia .app-config (archivo eliminado)

if [ -f "README.md" ]; then
    log_info "   📖 Copiando README original..."
    cp README.md "$NEW_APP_DIR/README-original.md"
fi

# Copiar archivos de configuración
log_info "   🌱 Copiando archivos de entorno..."
if [ -f "env.example" ]; then
    cp env.example "$NEW_APP_DIR/"
fi

# Crear directorio app vacío
log_info "   📱 Creando directorio app..."
mkdir -p "$NEW_APP_DIR/app"

# Crear archivo .gitignore
echo ""
log_info "📝 Creando archivo .gitignore..."
cat > "$NEW_APP_DIR/.gitignore" << EOF
# Laravel
app/
!app/.gitkeep

# Docker
.env.local

# Backups
backups/

# OS
.DS_Store
Thumbs.db

# IDEs
.idea/
.vscode/
*.swp
*.swo

# Logs
*.log
EOF

# Actualizar nombres en docker-compose.yml
echo ""
log_info "🔄 Personalizando archivos para '$NEW_APP_NAME'..."
echo ""
log_info "   🐳 Actualizando docker-compose.yml..."
# Actualizar container_name para la estructura unificada
sed -i.bak "s/container_name: \${APP_NAME:-${BASE_APP_NAME}}_app/container_name: \${APP_NAME:-${NEW_APP_NAME}}_app/g" "$NEW_APP_DIR/docker-compose.yml"
# Actualizar PHP_IDE_CONFIG
sed -i.bak "s/serverName=${BASE_APP_NAME}/serverName=${NEW_APP_NAME}/g" "$NEW_APP_DIR/docker-compose.yml"
rm "$NEW_APP_DIR/docker-compose.yml.bak"

# No hay docker-compose.production.yml en la nueva estructura

# Actualizar Makefile
log_info "   ⚙️  Actualizando Makefile..."
sed -i.bak "s/BASE_APP_NAME=${BASE_APP_NAME}/BASE_APP_NAME=${NEW_APP_NAME}/g" "$NEW_APP_DIR/Makefile"
rm "$NEW_APP_DIR/Makefile.bak"

# No se actualiza .app-config (archivo eliminado)

# Actualizar configuraciones de Docker
if [ -f "$NEW_APP_DIR/docker/nginx/conf.d/laravel.conf" ]; then
    log_info "   🌐 Actualizando configuración Nginx..."
    # Actualizar server_name en la configuración de nginx
    sed -i.bak "s/server_name localhost ${BASE_APP_NAME}\.local/server_name localhost ${NEW_APP_NAME}\.local/g" "$NEW_APP_DIR/docker/nginx/conf.d/laravel.conf"
    sed -i.bak "s/\*\.${BASE_APP_NAME}\.local/\*\.${NEW_APP_NAME}\.local/g" "$NEW_APP_DIR/docker/nginx/conf.d/laravel.conf"
    rm "$NEW_APP_DIR/docker/nginx/conf.d/laravel.conf.bak"
fi

# Actualizar archivos de entorno
if [ -f "$NEW_APP_DIR/env.example" ]; then
    log_info "   🌱 Actualizando env.example..."
    # Actualizar APP_NAME en env.example
    sed -i.bak "s/APP_NAME=${BASE_APP_NAME}/APP_NAME=${NEW_APP_NAME}/g" "$NEW_APP_DIR/env.example"
    # Actualizar APP_URL si contiene el nombre de la aplicación
    sed -i.bak "s/${BASE_APP_NAME}\.superbasicos\.com\.tes/${NEW_APP_NAME}\.superbasicos\.com\.tes/g" "$NEW_APP_DIR/env.example"
    rm "$NEW_APP_DIR/env.example.bak"
fi

# No hay env.production en la nueva estructura

# Hacer scripts ejecutables
echo ""
log_info "🔧 Configurando permisos de scripts..."
if [ -d "$NEW_APP_DIR/scripts" ]; then
    chmod +x "$NEW_APP_DIR/scripts/"*.sh 2>/dev/null || true
fi

# Crear README.md para la nueva aplicación
echo ""
log_info "📚 Personalizando README.md..."
# Copiar el README existente y personalizarlo
cp README.md "$NEW_APP_DIR/README.md"

# Personalizar el README para la nueva aplicación
sed -i.bak "s/# Plantilla Laravel Simplificada/# $NEW_APP_NAME/g" "$NEW_APP_DIR/README.md"
sed -i.bak "s/Una plantilla \*\*ultra-simplificada\*\* de Docker para desarrollar y desplegar aplicaciones Laravel con \*\*una sola imagen y un solo contenedor\*\*./Aplicación Laravel con Docker unificado, configurada con Laravel Reverb para WebSockets./g" "$NEW_APP_DIR/README.md"
sed -i.bak "s/sboil/$NEW_APP_NAME/g" "$NEW_APP_DIR/README.md"
sed -i.bak "s/<nombreapp>_app/${NEW_APP_NAME}_app/g" "$NEW_APP_DIR/README.md"
rm "$NEW_APP_DIR/README.md.bak"

echo ""
echo "════════════════════════════════════════════════════════════════"
log_success "🎉 ¡PLANTILLA COPIADA EXITOSAMENTE! 🎉"
echo "════════════════════════════════════════════════════════════════"
echo ""
log_info "📍 Nueva aplicación creada en:"
echo "   $NEW_APP_DIR"
echo ""
log_info "📁 Archivos importantes creados:"
echo "   📖 README.md                 - Documentación de la nueva aplicación"
echo "   📘 README-original.md        - Documentación original de la plantilla"
# .app-config eliminado del proyecto
echo "   🐳 docker-compose.yml       - Configuración Docker"
echo "   ⚙️  Makefile                - Comandos automatizados"
echo ""
log_info "🚀 PRÓXIMOS PASOS:"
echo "   1️⃣  cd $NEW_APP_DIR"
echo "   2️⃣  make fresh                # Instalación completa automática"
echo "   3️⃣  make dev                  # Iniciar desarrollo"
echo ""
log_info "🛠️  COMANDOS ÚTILES:"
echo "   📋 make help                  # Ver todos los comandos disponibles"
echo "   📊 make logs                  # Ver logs en tiempo real"
echo "   🐚 make shell                 # Acceder al contenedor unificado"
echo "   🔧 make artisan cmd=\"...\"     # Ejecutar comandos artisan"
echo "   🚀 make install-livewire      # Instalar Laravel Livewire"
echo "   🔌 make install-reverb        # Instalar Laravel Reverb"
echo ""
echo "════════════════════════════════════════════════════════════════"
log_success "✨ ¡La aplicación '$NEW_APP_NAME' está lista para usar! ✨"
echo "════════════════════════════════════════════════════════════════"
