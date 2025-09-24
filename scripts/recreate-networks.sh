#!/bin/bash

# Script para recrear redes Docker importantes que pueden haber sido eliminadas accidentalmente

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== RECREANDO REDES DOCKER IMPORTANTES ===${NC}"
echo ""

# Lista de redes importantes que deben existir
NETWORKS=(
    "red_general"
    "webodm_default"
    "cloudflare_default"
)

for network in "${NETWORKS[@]}"; do
    echo -e "${YELLOW}Verificando red: ${network}${NC}"

    if docker network ls | grep -q "$network"; then
        echo -e "${GREEN}✓ La red '${network}' ya existe${NC}"
    else
        echo -e "${YELLOW}⚠️  La red '${network}' no existe, creándola...${NC}"
        if docker network create "$network" >/dev/null 2>&1; then
            echo -e "${GREEN}✓ Red '${network}' creada exitosamente${NC}"
        else
            echo -e "${RED}✗ Error al crear la red '${network}'${NC}"
        fi
    fi
    echo ""
done

echo -e "${BLUE}=== ESTADO FINAL DE REDES ===${NC}"
docker network ls

echo ""
echo -e "${GREEN}✓ Verificación y recreación de redes completada${NC}"
