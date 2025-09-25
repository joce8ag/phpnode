#!/bin/bash

# Script para copiar plantilla a nueva aplicación
# Uso: ./scripts/copy-template.sh <nombre_nueva_aplicacion> [directorio_destino]

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

if [ -f "docker-compose.production.yml" ]; then
    log_info "   🚀 Copiando docker-compose.production.yml..."
    cp docker-compose.production.yml "$NEW_APP_DIR/"
fi

log_info "   ⚙️  Copiando Makefile..."
cp Makefile "$NEW_APP_DIR/"

log_info "   📜 Copiando scripts..."
cp -r scripts/ "$NEW_APP_DIR/"

log_info "   🔐 Copiando .app-config..."
cp .app-config "$NEW_APP_DIR/"

if [ -f "README.md" ]; then
    log_info "   📖 Copiando README original..."
    cp README.md "$NEW_APP_DIR/README-original.md"
fi

# Copiar archivos de configuración
log_info "   🌱 Copiando archivos de entorno..."
if [ -f "env.example" ]; then
    cp env.example "$NEW_APP_DIR/"
fi

if [ -f "env.production" ]; then
    cp env.production "$NEW_APP_DIR/"
fi

# Crear directorio app vacío
log_info "   📱 Creando directorio app..."
mkdir -p "$NEW_APP_DIR/app"

# Crear archivo .gitignore
echo ""
log_info "📝 Creando archivo .gitignore..."
cat > "$NEW_APP_DIR/.gitignore" << EOF
# Laravel
/app/vendor/
/app/node_modules/
/app/public/hot
/app/public/storage
/app/storage/*.key
/app/.env
/app/.env.backup
/app/.phpunit.result.cache
/app/Homestead.json
/app/Homestead.yaml
/app/npm-debug.log
/app/yarn-error.log
/app/.idea
/app/.vscode

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
sed -i.bak "s/${BASE_APP_NAME}_/${NEW_APP_NAME}_/g" "$NEW_APP_DIR/docker-compose.yml"
sed -i.bak "s/${BASE_APP_NAME}/${NEW_APP_NAME}/g" "$NEW_APP_DIR/docker-compose.yml"
rm "$NEW_APP_DIR/docker-compose.yml.bak"

# Actualizar docker-compose.production.yml si existe
if [ -f "$NEW_APP_DIR/docker-compose.production.yml" ]; then
    log_info "   🚀 Actualizando docker-compose.production.yml..."
    sed -i.bak "s/${BASE_APP_NAME}_/${NEW_APP_NAME}_/g" "$NEW_APP_DIR/docker-compose.production.yml"
    sed -i.bak "s/${BASE_APP_NAME}/${NEW_APP_NAME}/g" "$NEW_APP_DIR/docker-compose.production.yml"
    rm "$NEW_APP_DIR/docker-compose.production.yml.bak"
fi

# Actualizar Makefile
log_info "   ⚙️  Actualizando Makefile..."
sed -i.bak "s/BASE_APP_NAME=${BASE_APP_NAME}/BASE_APP_NAME=${NEW_APP_NAME}/g" "$NEW_APP_DIR/Makefile"
rm "$NEW_APP_DIR/Makefile.bak"

# Actualizar .app-config
log_info "   🔐 Actualizando .app-config..."
sed -i.bak "s/APP_NAME=${BASE_APP_NAME}/APP_NAME=${NEW_APP_NAME}/g" "$NEW_APP_DIR/.app-config"
rm "$NEW_APP_DIR/.app-config.bak"

# Actualizar configuraciones de Docker
if [ -f "$NEW_APP_DIR/docker/nginx/conf.d/laravel.conf" ]; then
    log_info "   🌐 Actualizando configuración Nginx..."
    sed -i.bak "s/${BASE_APP_NAME}\.local/${NEW_APP_NAME}\.local/g" "$NEW_APP_DIR/docker/nginx/conf.d/laravel.conf"
    sed -i.bak "s/\*\.${BASE_APP_NAME}\.local/\*\.${NEW_APP_NAME}\.local/g" "$NEW_APP_DIR/docker/nginx/conf.d/laravel.conf"
    rm "$NEW_APP_DIR/docker/nginx/conf.d/laravel.conf.bak"
fi

# Actualizar archivos de entorno
if [ -f "$NEW_APP_DIR/env.example" ]; then
    log_info "   🌱 Actualizando env.example..."
    sed -i.bak "s/APP_NAME=SBoil/APP_NAME=$NEW_APP_NAME/g" "$NEW_APP_DIR/env.example"
    rm "$NEW_APP_DIR/env.example.bak"
fi

if [ -f "$NEW_APP_DIR/env.production" ]; then
    log_info "   🏭 Actualizando env.production..."
    sed -i.bak "s/APP_NAME=SBoil/APP_NAME=$NEW_APP_NAME/g" "$NEW_APP_DIR/env.production"
    rm "$NEW_APP_DIR/env.production.bak"
fi

# Hacer scripts ejecutables
echo ""
log_info "🔧 Configurando permisos de scripts..."
chmod +x "$NEW_APP_DIR/scripts/"*.sh

# Crear README.md para la nueva aplicación
echo ""
log_info "📚 Creando README.md personalizado..."
cat > "$NEW_APP_DIR/README.md" << EOF
# $NEW_APP_NAME

Aplicación Laravel con Docker, configurada con Laravel Reverb para WebSockets.

## Características

- **PHP 8.4** con PHP-FPM
- **Nginx** como servidor web
- **Node.js 22** para Vite
- **Laravel Reverb** para WebSockets en tiempo real
- **Redis** para cache y sesiones
- **Queue Workers** para procesamiento en background
- **Scheduler** para tareas programadas

## Inicio Rápido

### 1. Instalación inicial completa

\`\`\`bash
# Inicializar aplicación completa
./scripts/init.sh

# O usar make para instalación completa
make fresh
\`\`\`

### 2. Desarrollo

\`\`\`bash
# Iniciar entorno de desarrollo
make dev

# Ver logs en tiempo real
make logs

# Acceder al contenedor PHP
make shell

# Ejecutar comandos artisan
make artisan cmd="migrate"

# Instalar dependencias npm
make npm-install

# Iniciar servidor de desarrollo Vite
make npm-dev
\`\`\`

### 3. Comandos útiles

\`\`\`bash
# Ver todos los comandos disponibles
make help

# Estado de contenedores
make status

# Reiniciar servicios
make restart

# Limpiar cache
make clear-cache

# Ejecutar tests
make test
\`\`\`

## Puertos

- **80**: Aplicación web (HTTP)
- **8080**: Laravel Reverb (WebSockets)
- **5173**: Vite dev server
- **6379**: Redis

> **Nota:** Para HTTPS/SSL usar Nginx Proxy Manager u otro proxy reverso.

## Estructura

\`\`\`
$NEW_APP_NAME/
├── app/                    # Código de Laravel
├── docker/                 # Configuraciones Docker
│   ├── nginx/             # Configuración Nginx
│   ├── php/               # Configuración PHP-FPM
│   └── node/              # Configuración Node.js
├── scripts/               # Scripts de automatización
├── docker-compose.yml     # Configuración Docker Compose
├── Makefile              # Comandos abreviados
└── README.md             # Este archivo
\`\`\`

## Despliegue en Producción

\`\`\`bash
# Desplegar en producción
./scripts/deploy.sh production

# O usar make
make deploy-prod
\`\`\`

## Red Externa

Esta aplicación se conecta a la red Docker externa \`red_general\` para comunicarse con la base de datos y otros servicios.

## Personalización

Para crear una nueva aplicación basada en esta plantilla:

\`\`\`bash
./scripts/copy-template.sh nueva-aplicacion /ruta/destino/
\`\`\`

## Soporte

Para más información sobre comandos disponibles: \`make help\`
EOF

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
echo "   🔐 .app-config              - Configuración de la aplicación"
echo "   🐳 docker-compose.yml       - Configuración Docker"
echo "   ⚙️  Makefile                - Comandos automatizados"
echo ""
log_info "🚀 PRÓXIMOS PASOS:"
echo "   1️⃣  cd $NEW_APP_DIR"
echo "   2️⃣  ./scripts/init.sh         # Instalación completa automática"
echo "   3️⃣  make dev                  # Iniciar desarrollo"
echo ""
log_info "🛠️  COMANDOS ÚTILES:"
echo "   📋 make help                  # Ver todos los comandos disponibles"
echo "   📊 make logs                  # Ver logs en tiempo real"
echo "   🐚 make shell                 # Acceder al contenedor PHP"
echo "   🔧 make artisan cmd=\"...\"     # Ejecutar comandos artisan"
echo ""
echo "════════════════════════════════════════════════════════════════"
log_success "✨ ¡La aplicación '$NEW_APP_NAME' está lista para usar! ✨"
echo "════════════════════════════════════════════════════════════════"
