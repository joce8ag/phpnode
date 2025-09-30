#!/bin/bash

# Script para actualizar el nombre de la aplicación en la estructura simplificada
# Uso: ./scripts/update-app-name.sh <nuevo_nombre>

set -e

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
    log_error "Uso: $0 <nuevo_nombre>"
    log_info "Ejemplo: $0 mi-nueva-app"
    exit 1
fi

NEW_APP_NAME=$1

# Detectar el nombre actual desde docker-compose.yml
if [ -f "docker-compose.yml" ]; then
    # Extraer el nombre actual del container_name
    CURRENT_APP_NAME=$(grep "container_name:" docker-compose.yml | sed 's/.*\${APP_NAME:\([^}]*\)}.*/\1/')
    if [ -z "$CURRENT_APP_NAME" ]; then
        CURRENT_APP_NAME="sboil"
    fi
else
    CURRENT_APP_NAME="sboil"
fi

log_info "Actualizando nombre de aplicación de '$CURRENT_APP_NAME' a '$NEW_APP_NAME'"

# Verificar que no sea el mismo nombre
if [ "$CURRENT_APP_NAME" = "$NEW_APP_NAME" ]; then
    log_warning "El nuevo nombre es igual al actual. No hay cambios que hacer."
    exit 0
fi

# No necesitamos backup para cambios tan simples

# No se actualiza .app-config (archivo eliminado)

# 2. Actualizar docker-compose.yml
log_info "Actualizando docker-compose.yml..."
# Actualizar container_name
sed -i.bak "s/container_name: \${APP_NAME:${CURRENT_APP_NAME}}_app/container_name: \${APP_NAME:${NEW_APP_NAME}}_app/g" docker-compose.yml
# Actualizar PHP_IDE_CONFIG
sed -i.bak "s/serverName=${CURRENT_APP_NAME}/serverName=${NEW_APP_NAME}/g" docker-compose.yml
rm docker-compose.yml.bak

# 3. Actualizar Makefile
log_info "Actualizando Makefile..."
sed -i.bak "s/BASE_APP_NAME=$CURRENT_APP_NAME/BASE_APP_NAME=$NEW_APP_NAME/g" Makefile
rm Makefile.bak

# 4. Actualizar README.md
if [ -f "README.md" ]; then
    log_info "Actualizando README.md..."
    sed -i.bak "s/sboil/$NEW_APP_NAME/g" README.md
    sed -i.bak "s/<nombreapp>_app/${NEW_APP_NAME}_app/g" README.md
    rm README.md.bak
fi

# Resumen
echo ""
log_success "¡Actualización completada exitosamente!"
echo ""
log_info "Cambios realizados:"
echo -e "  ${GREEN}Nombre anterior:${NC} $CURRENT_APP_NAME"
echo -e "  ${GREEN}Nombre nuevo:${NC} $NEW_APP_NAME"
echo ""
log_info "Archivos actualizados:"
# .app-config eliminado del proyecto
echo "  - docker-compose.yml (container_name y PHP_IDE_CONFIG)"
echo "  - Makefile (BASE_APP_NAME)"
echo "  - README.md (referencias al nombre)"
echo ""
log_warning "IMPORTANTE: Si tienes contenedores ejecutándose, ejecuta:"
echo "  make down"
echo "  make clean"
echo "  make build"
echo "  make up"
echo ""
log_info "Estructura actualizada:"
echo "  - Contenedor: ${NEW_APP_NAME}_app"
echo "  - Imagen: webapp:latest"
echo "  - Servicios: Nginx + PHP-FPM + Node.js + Redis + Supervisor"
echo ""
log_success "¡La aplicación ahora se llama '$NEW_APP_NAME'!"
