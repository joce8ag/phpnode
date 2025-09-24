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

# Verificar argumentos
if [ $# -lt 1 ]; then
    log_error "Uso: $0 <nombre_nueva_aplicacion> [directorio_destino]"
    log_info "Ejemplo: $0 mi-nueva-app /ruta/a/proyectos/"
    exit 1
fi

NEW_APP_NAME=$1
DEST_DIR=${2:-"../"}
CURRENT_DIR=$(pwd)
NEW_APP_DIR="$DEST_DIR/$NEW_APP_NAME"

log_info "Copiando plantilla a nueva aplicación: $NEW_APP_NAME"
log_info "Directorio destino: $NEW_APP_DIR"

# Verificar que no existe el directorio destino
if [ -d "$NEW_APP_DIR" ]; then
    log_error "El directorio '$NEW_APP_DIR' ya existe"
    read -p "¿Deseas continuar y sobrescribir? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Operación cancelada"
        exit 1
    fi
    log_warning "Sobrescribiendo directorio existente..."
    rm -rf "$NEW_APP_DIR"
fi

# Crear directorio base
log_info "Creando estructura de directorios..."
mkdir -p "$NEW_APP_DIR"

# Copiar archivos y directorios necesarios (excluyendo app/ y backups/)
log_info "Copiando archivos de plantilla..."
cp -r docker/ "$NEW_APP_DIR/"
cp docker-compose.yml "$NEW_APP_DIR/"
cp Makefile "$NEW_APP_DIR/"
cp -r scripts/ "$NEW_APP_DIR/"

# Copiar archivos de configuración
if [ -f "env.example" ]; then
    cp env.example "$NEW_APP_DIR/"
fi

if [ -f "env.production" ]; then
    cp env.production "$NEW_APP_DIR/"
fi

# Crear directorio app vacío
mkdir -p "$NEW_APP_DIR/app"

# Crear archivo .gitignore
log_info "Creando archivo .gitignore..."
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
log_info "Actualizando configuración para $NEW_APP_NAME..."
sed -i.bak "s/${BASE_APP_NAME}_/${NEW_APP_NAME}_/g" "$NEW_APP_DIR/docker-compose.yml"
sed -i.bak "s/${BASE_APP_NAME}/${NEW_APP_NAME}/g" "$NEW_APP_DIR/docker-compose.yml"
rm "$NEW_APP_DIR/docker-compose.yml.bak"

# Actualizar docker-compose.production.yml si existe
if [ -f "$NEW_APP_DIR/docker-compose.production.yml" ]; then
    sed -i.bak "s/${BASE_APP_NAME}_/${NEW_APP_NAME}_/g" "$NEW_APP_DIR/docker-compose.production.yml"
    sed -i.bak "s/${BASE_APP_NAME}/${NEW_APP_NAME}/g" "$NEW_APP_DIR/docker-compose.production.yml"
    rm "$NEW_APP_DIR/docker-compose.production.yml.bak"
fi

# Actualizar Makefile
sed -i.bak "s/${BASE_APP_NAME}_/${NEW_APP_NAME}_/g" "$NEW_APP_DIR/Makefile"
sed -i.bak "s/APP_CONTAINER=${BASE_APP_NAME}_php/APP_CONTAINER=${NEW_APP_NAME}_php/g" "$NEW_APP_DIR/Makefile"
sed -i.bak "s/NODE_CONTAINER=${BASE_APP_NAME}_node/NODE_CONTAINER=${NEW_APP_NAME}_node/g" "$NEW_APP_DIR/Makefile"
sed -i.bak "s/NGINX_CONTAINER=${BASE_APP_NAME}_nginx/NGINX_CONTAINER=${NEW_APP_NAME}_nginx/g" "$NEW_APP_DIR/Makefile"
sed -i.bak "s/REDIS_CONTAINER=${BASE_APP_NAME}_redis/REDIS_CONTAINER=${NEW_APP_NAME}_redis/g" "$NEW_APP_DIR/Makefile"
rm "$NEW_APP_DIR/Makefile.bak"

# Actualizar script de inicialización
sed -i.bak "s/APP_NAME=\${1:-\"${BASE_APP_NAME}\"}/APP_NAME=\${1:-\"$NEW_APP_NAME\"}/g" "$NEW_APP_DIR/scripts/init.sh"
rm "$NEW_APP_DIR/scripts/init.sh.bak"

# Actualizar archivos de entorno
if [ -f "$NEW_APP_DIR/env.example" ]; then
    sed -i.bak "s/APP_NAME=SBoil/APP_NAME=$NEW_APP_NAME/g" "$NEW_APP_DIR/env.example"
    rm "$NEW_APP_DIR/env.example.bak"
fi

if [ -f "$NEW_APP_DIR/env.production" ]; then
    sed -i.bak "s/APP_NAME=SBoil/APP_NAME=$NEW_APP_NAME/g" "$NEW_APP_DIR/env.production"
    rm "$NEW_APP_DIR/env.production.bak"
fi

# Hacer scripts ejecutables
log_info "Configurando permisos de scripts..."
chmod +x "$NEW_APP_DIR/scripts/"*.sh

# Crear README.md para la nueva aplicación
log_info "Creando README.md..."
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
- **443**: Aplicación web (HTTPS)
- **8080**: Laravel Reverb (WebSockets)
- **5173**: Vite dev server
- **6379**: Redis

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

log_success "¡Plantilla copiada exitosamente!"
echo ""
log_info "Nueva aplicación creada en: $NEW_APP_DIR"
echo ""
log_info "Próximos pasos:"
echo "  1. cd $NEW_APP_DIR"
echo "  2. ./scripts/init.sh    # Para instalación completa automática"
echo "  3. make dev             # Para iniciar desarrollo"
echo ""
log_info "Comandos útiles:"
echo "  make help               # Ver todos los comandos disponibles"
echo "  make logs               # Ver logs en tiempo real"
echo "  make shell              # Acceder al contenedor PHP"
echo ""
log_success "¡La nueva aplicación $NEW_APP_NAME está lista!"
