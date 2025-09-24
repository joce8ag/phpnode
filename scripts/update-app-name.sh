#!/bin/bash

# Script para actualizar el nombre de la aplicación en todos los archivos
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

# Leer configuración actual
if [ -f ".app-config" ]; then
    source .app-config
    CURRENT_APP_NAME=$APP_NAME
else
    log_warning "Archivo .app-config no encontrado, usando 'sboil' como nombre actual"
    CURRENT_APP_NAME="sboil"
fi

log_info "Actualizando nombre de aplicación de '$CURRENT_APP_NAME' a '$NEW_APP_NAME'"

# Verificar que no sea el mismo nombre
if [ "$CURRENT_APP_NAME" = "$NEW_APP_NAME" ]; then
    log_warning "El nuevo nombre es igual al actual. No hay cambios que hacer."
    exit 0
fi

# Crear backup
BACKUP_DIR="backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
mkdir -p $BACKUP_DIR

log_info "Creando backup antes de la actualización..."
tar -czf "$BACKUP_DIR/pre-rename-$TIMESTAMP.tar.gz" \
    docker-compose.yml \
    docker-compose.production.yml \
    Makefile \
    scripts/ \
    .app-config \
    env.example \
    env.production \
    --exclude=backups/

log_success "Backup creado: $BACKUP_DIR/pre-rename-$TIMESTAMP.tar.gz"

# Actualizar .app-config
log_info "Actualizando .app-config..."
sed -i.bak "s/APP_NAME=$CURRENT_APP_NAME/APP_NAME=$NEW_APP_NAME/g" .app-config
rm .app-config.bak

# Actualizar docker-compose.yml
log_info "Actualizando docker-compose.yml..."
sed -i.bak "s/${CURRENT_APP_NAME}_/${NEW_APP_NAME}_/g" docker-compose.yml
sed -i.bak "s/container_name: ${CURRENT_APP_NAME}_/container_name: ${NEW_APP_NAME}_/g" docker-compose.yml
rm docker-compose.yml.bak

# Actualizar docker-compose.production.yml
if [ -f "docker-compose.production.yml" ]; then
    log_info "Actualizando docker-compose.production.yml..."
    sed -i.bak "s/${CURRENT_APP_NAME}_/${NEW_APP_NAME}_/g" docker-compose.production.yml
    sed -i.bak "s/container_name: ${CURRENT_APP_NAME}_/container_name: ${NEW_APP_NAME}_/g" docker-compose.production.yml
    rm docker-compose.production.yml.bak
fi

# Actualizar Makefile
log_info "Actualizando Makefile..."
sed -i.bak "s/BASE_APP_NAME=$CURRENT_APP_NAME/BASE_APP_NAME=$NEW_APP_NAME/g" Makefile
rm Makefile.bak

# Actualizar scripts
log_info "Actualizando scripts..."
for script in scripts/*.sh; do
    if [ -f "$script" ]; then
        sed -i.bak "s/BASE_APP_NAME=\"$CURRENT_APP_NAME\"/BASE_APP_NAME=\"$NEW_APP_NAME\"/g" "$script"
        rm "$script.bak"
    fi
done

# Actualizar archivos de entorno
if [ -f "env.example" ]; then
    log_info "Actualizando env.example..."
    # Capitalizar primera letra para APP_NAME
    NEW_APP_NAME_CAPITALIZED=$(echo "$NEW_APP_NAME" | sed 's/./\U&/')
    sed -i.bak "s/APP_NAME=SBoil/APP_NAME=$NEW_APP_NAME_CAPITALIZED/g" env.example
    rm env.example.bak
fi

if [ -f "env.production" ]; then
    log_info "Actualizando env.production..."
    # Capitalizar primera letra para APP_NAME
    NEW_APP_NAME_CAPITALIZED=$(echo "$NEW_APP_NAME" | sed 's/./\U&/')
    sed -i.bak "s/APP_NAME=SBoil/APP_NAME=$NEW_APP_NAME_CAPITALIZED/g" env.production
    rm env.production.bak
fi

# Actualizar README.md si existe
if [ -f "README.md" ]; then
    log_info "Actualizando README.md..."
    sed -i.bak "s/# SBoil/# $NEW_APP_NAME/g" README.md
    sed -i.bak "s/sboil/$NEW_APP_NAME/g" README.md
    rm README.md.bak
fi

# Crear backup post-actualización
log_info "Creando backup post-actualización..."
tar -czf "$BACKUP_DIR/post-rename-$TIMESTAMP.tar.gz" \
    docker-compose.yml \
    docker-compose.production.yml \
    Makefile \
    scripts/ \
    .app-config \
    env.example \
    env.production \
    README.md \
    --exclude=backups/

log_success "Backup post-actualización creado: $BACKUP_DIR/post-rename-$TIMESTAMP.tar.gz"

# Resumen
echo ""
log_success "¡Actualización completada exitosamente!"
echo ""
log_info "Cambios realizados:"
echo -e "  ${GREEN}Nombre anterior:${NC} $CURRENT_APP_NAME"
echo -e "  ${GREEN}Nombre nuevo:${NC} $NEW_APP_NAME"
echo ""
log_info "Archivos actualizados:"
echo "  - .app-config"
echo "  - docker-compose.yml"
echo "  - docker-compose.production.yml (si existe)"
echo "  - Makefile"
echo "  - scripts/*.sh"
echo "  - env.example (si existe)"
echo "  - env.production (si existe)"
echo "  - README.md (si existe)"
echo ""
log_info "Backups creados:"
echo "  - Pre-actualización: $BACKUP_DIR/pre-rename-$TIMESTAMP.tar.gz"
echo "  - Post-actualización: $BACKUP_DIR/post-rename-$TIMESTAMP.tar.gz"
echo ""
log_warning "IMPORTANTE: Si tienes contenedores ejecutándose, ejecuta:"
echo "  make down"
echo "  make clean"
echo "  make build"
echo "  make up"
echo ""
log_success "¡La aplicación ahora se llama '$NEW_APP_NAME'!"
