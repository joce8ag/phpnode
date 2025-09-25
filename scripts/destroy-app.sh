#!/bin/bash

# Script para eliminar completamente todos los recursos de Docker relacionados con la aplicación
# Preserva todas las redes y recursos externos

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Obtener el nombre de la aplicación desde el argumento o desde el Makefile
if [ "$1" ]; then
    BASE_APP_NAME="$1"
else
    # Leer el nombre desde el Makefile si no se proporciona argumento
    if [ -f "Makefile" ]; then
        BASE_APP_NAME=$(grep "^BASE_APP_NAME=" Makefile | cut -d'=' -f2)
    else
        echo -e "${RED}Error: No se pudo determinar el nombre de la aplicación${NC}"
        echo -e "${YELLOW}Uso: $0 [nombre-aplicacion]${NC}"
        echo -e "${YELLOW}O ejecutar desde el directorio que contiene el Makefile${NC}"
        exit 1
    fi
fi

echo -e "${RED}⚠️  ADVERTENCIA: Esto eliminará SOLO los recursos del proyecto ${BASE_APP_NAME}${NC}"
echo -e "${RED}⚠️  Incluyendo: contenedores, imágenes, volúmenes y red de aplicación${NC}"
echo -e "${GREEN}✓ Se preservarán TODAS las otras redes y recursos de Docker${NC}"
echo ""

# Lista de recursos que se eliminarán
echo -e "${BLUE}=== RECURSOS QUE SE ELIMINARÁN ===${NC}"
echo -e "${YELLOW}Contenedores:${NC}"
docker ps -a --filter "name=${BASE_APP_NAME}" --format "  - {{.Names}} ({{.Status}})" 2>/dev/null || echo "  No hay contenedores"

echo -e "${YELLOW}Imágenes:${NC}"
docker images --filter "reference=*${BASE_APP_NAME}*" --format "  - {{.Repository}}:{{.Tag}}" 2>/dev/null || echo "  No hay imágenes"

echo -e "${YELLOW}Volúmenes:${NC}"
docker volume ls --filter "name=${BASE_APP_NAME}" --format "  - {{.Name}}" 2>/dev/null || echo "  No hay volúmenes"

echo -e "${YELLOW}Redes:${NC}"
docker network ls --filter "name=${BASE_APP_NAME}" --format "  - {{.Name}}" 2>/dev/null || echo "  No hay redes de aplicación"

echo ""
read -p "¿Estás seguro? Esta acción NO se puede deshacer [y/N] " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Iniciando eliminación completa...${NC}"

    # 1. Detener y eliminar contenedores con docker-compose
    echo -e "${YELLOW}1. Deteniendo y eliminando contenedores con docker-compose...${NC}"
    if [ -f "docker-compose.yml" ]; then
        docker-compose -f docker-compose.yml down -v --remove-orphans 2>/dev/null || true
    fi
    if [ -f "docker-compose.production.yml" ]; then
        docker-compose -f docker-compose.production.yml down -v --remove-orphans 2>/dev/null || true
    fi

    # 2. Eliminar contenedores específicos que puedan quedar
    echo -e "${YELLOW}2. Eliminando contenedores específicos...${NC}"
    docker ps -a --filter "name=${BASE_APP_NAME}" -q | xargs -r docker rm -f 2>/dev/null || true

    # 3. Eliminar volúmenes específicos
    echo -e "${YELLOW}3. Eliminando volúmenes específicos...${NC}"
    docker volume rm -f \
        "${BASE_APP_NAME}_redis_data" \
        "${BASE_APP_NAME}_nginx_cache" \
        redis_data \
        nginx_cache \
        2>/dev/null || true

    # 4. Eliminar volúmenes que contengan el nombre del proyecto
    echo -e "${YELLOW}4. Eliminando volúmenes adicionales...${NC}"
    docker volume ls --filter "name=${BASE_APP_NAME}" -q | xargs -r docker volume rm -f 2>/dev/null || true

    # 5. Eliminar imágenes del proyecto
    echo -e "${YELLOW}5. Eliminando imágenes del proyecto...${NC}"
    docker images --filter "reference=*${BASE_APP_NAME}*" -q | xargs -r docker rmi -f 2>/dev/null || true

    # 6. Eliminar red de aplicación (preservar red_general)
    echo -e "${YELLOW}6. Eliminando red de aplicación...${NC}"
    docker network rm "${BASE_APP_NAME}_app_network" 2>/dev/null || true

    echo ""
    echo -e "${GREEN}✓ Eliminación del proyecto ${BASE_APP_NAME} finalizada${NC}"
    echo -e "${BLUE}✓ Todas las demás redes y recursos de Docker preservados${NC}"

    # Verificar que otras redes siguen existiendo
    echo -e "${YELLOW}Verificando preservación de otras redes...${NC}"
    PRESERVED_NETWORKS=$(docker network ls --format "{{.Name}}" | grep -v "bridge\|host\|none\|${BASE_APP_NAME}" | wc -l)
    if [ "$PRESERVED_NETWORKS" -gt 0 ]; then
        echo -e "${GREEN}✓ ${PRESERVED_NETWORKS} redes externas preservadas correctamente${NC}"
        docker network ls --format "  - {{.Name}}" | grep -v "bridge\|host\|none\|${BASE_APP_NAME}" | head -5
    else
        echo -e "${YELLOW}⚠️  No se encontraron otras redes (normal si no había otras)${NC}"
    fi

else
    echo -e "${GREEN}Operación cancelada${NC}"
fi
