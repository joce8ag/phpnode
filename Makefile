# Makefile para aplicación Laravel con Docker
# Uso: make [comando]

.PHONY: help build up down restart logs shell php-shell node-shell nginx-shell redis-shell composer npm artisan install-laravel fresh migrate seed optimize test backup restore deploy clean

# Variables de configuración
BASE_APP_NAME=sboil
COMPOSE_FILE=docker-compose.yml
APP_CONTAINER=$(BASE_APP_NAME)_php
NODE_CONTAINER=$(BASE_APP_NAME)_node
NGINX_CONTAINER=$(BASE_APP_NAME)_nginx
REDIS_CONTAINER=$(BASE_APP_NAME)_redis

# Colores para output
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[1;33m
BLUE=\033[0;34m
NC=\033[0m # No Color

# Comando por defecto
help: ## Mostrar esta ayuda
	@echo "$(BLUE)Comandos disponibles:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

# === COMANDOS DE DOCKER ===
build: ## Construir las imágenes Docker
	@echo "$(YELLOW)Construyendo imágenes Docker...$(NC)"
	docker-compose -f $(COMPOSE_FILE) build

up: ## Levantar todos los contenedores
	@echo "$(YELLOW)Iniciando contenedores...$(NC)"
	docker-compose -f $(COMPOSE_FILE) up -d
	@echo "$(GREEN)Contenedores iniciados correctamente$(NC)"
	@echo "$(BLUE)Configura Nginx Proxy Manager para acceder a:$(NC)"
	@echo "$(GREEN)  - Aplicación: sboil_nginx (puerto 80)$(NC)"
	@echo "$(GREEN)  - WebSockets: sboil_reverb (puerto 8080)$(NC)"
	@echo "$(GREEN)  - Vite Dev: sboil_node (puerto 5173)$(NC)"

down: ## Detener todos los contenedores
	@echo "$(YELLOW)Deteniendo contenedores...$(NC)"
	docker-compose -f $(COMPOSE_FILE) down

restart: ## Reiniciar todos los contenedores
	@echo "$(YELLOW)Reiniciando contenedores...$(NC)"
	docker-compose -f $(COMPOSE_FILE) down
	docker-compose -f $(COMPOSE_FILE) up -d

# === COMANDOS DE MONITOREO ===
logs: ## Ver logs de todos los contenedores
	docker-compose -f $(COMPOSE_FILE) logs -f

logs-php: ## Ver logs del contenedor PHP
	docker-compose -f $(COMPOSE_FILE) logs -f php

logs-nginx: ## Ver logs del contenedor Nginx
	docker-compose -f $(COMPOSE_FILE) logs -f $(NGINX_CONTAINER)

logs-node: ## Ver logs del contenedor Node
	docker-compose -f $(COMPOSE_FILE) logs -f $(NODE_CONTAINER)

logs-reverb: ## Ver logs del contenedor Reverb
	docker-compose -f $(COMPOSE_FILE) logs -f sboil_reverb

logs-queue: ## Ver logs del contenedor Queue
	docker-compose -f $(COMPOSE_FILE) logs -f sboil_queue

status: ## Ver estado de los contenedores
	docker-compose -f $(COMPOSE_FILE) ps

# === SHELLS DE CONTENEDORES ===
shell: php-shell ## Acceder al shell del contenedor PHP (alias)

php-shell: ## Acceder al shell del contenedor PHP
	docker-compose -f $(COMPOSE_FILE) exec php bash

node-shell: ## Acceder al shell del contenedor Node
	docker-compose -f $(COMPOSE_FILE) exec $(NODE_CONTAINER) sh

nginx-shell: ## Acceder al shell del contenedor Nginx
	docker-compose -f $(COMPOSE_FILE) exec $(NGINX_CONTAINER) sh

redis-shell: ## Acceder al shell del contenedor Redis
	docker-compose -f $(COMPOSE_FILE) exec $(REDIS_CONTAINER) redis-cli

# === COMANDOS DE PHP/LARAVEL ===
composer: ## Ejecutar comando composer (usar: make composer cmd="install")
	docker-compose -f $(COMPOSE_FILE) exec php composer $(cmd)

artisan: ## Ejecutar comando artisan (usar: make artisan cmd="migrate")
	docker-compose -f $(COMPOSE_FILE) exec php php artisan $(cmd)

# === COMANDOS DE NODE ===
npm: ## Ejecutar comando npm (usar: make npm cmd="install")
	docker-compose -f $(COMPOSE_FILE) exec $(NODE_CONTAINER) npm $(cmd)

npm-install: ## Instalar dependencias npm
	docker-compose -f $(COMPOSE_FILE) exec $(NODE_CONTAINER) npm install

npm-dev: ## Ejecutar npm run dev
	docker-compose -f $(COMPOSE_FILE) exec $(NODE_CONTAINER) npm run dev

npm-build: ## Ejecutar npm run build
	docker-compose -f $(COMPOSE_FILE) exec $(NODE_CONTAINER) npm run build

npm-watch: ## Ejecutar npm run watch
	docker-compose -f $(COMPOSE_FILE) exec $(NODE_CONTAINER) npm run watch

# === INSTALACIÓN Y CONFIGURACIÓN ===
clean-app: ## Limpiar directorio app para nueva instalación
	@echo "$(YELLOW)Limpiando directorio app...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec php sh -c "rm -rf /var/www/html/* /var/www/html/.* 2>/dev/null || true"

install-laravel: ## Instalar Laravel dentro del contenedor
	@echo "$(YELLOW)Instalando Laravel...$(NC)"
	make clean-app
	docker-compose -f $(COMPOSE_FILE) exec php composer create-project laravel/laravel . --remove-vcs
	@echo "$(GREEN)Laravel instalado correctamente!$(NC)"

setup-env: ## Configurar archivo .env
	@if [ ! -f "./app/.env" ]; then \
		echo "$(YELLOW)Copiando archivo .env...$(NC)"; \
		docker-compose -f $(COMPOSE_FILE) exec php cp .env.example .env; \
	fi
	docker-compose -f $(COMPOSE_FILE) exec php php artisan key:generate

install-reverb: ## Instalar Laravel Reverb
	@echo "$(YELLOW)Instalando Laravel Reverb...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec php composer require laravel/reverb
	@echo "$(GREEN)Laravel Reverb instalado correctamente!$(NC)"
	@echo "$(YELLOW)Nota: Ejecutar manualmente 'php artisan reverb:install' si es necesario$(NC)"

fresh: ## Instalación completa desde cero
	@echo "$(YELLOW)Instalación completa...$(NC)"
	make build
	make up
	sleep 10
	make install-laravel
	make setup-env
	make install-reverb
	make migrate
	make npm-install
	@echo "$(GREEN)Instalación completada!$(NC)"

# === COMANDOS DE BASE DE DATOS ===
migrate: ## Ejecutar migraciones
	docker-compose -f $(COMPOSE_FILE) exec php php artisan migrate

migrate-fresh: ## Ejecutar migraciones desde cero
	docker-compose -f $(COMPOSE_FILE) exec php php artisan migrate:fresh

seed: ## Ejecutar seeders
	docker-compose -f $(COMPOSE_FILE) exec php php artisan db:seed

migrate-seed: ## Ejecutar migraciones y seeders
	docker-compose -f $(COMPOSE_FILE) exec php php artisan migrate:fresh --seed

# === COMANDOS DE OPTIMIZACIÓN ===
optimize: ## Optimizar aplicación para producción
	docker-compose -f $(COMPOSE_FILE) exec php php artisan config:cache
	docker-compose -f $(COMPOSE_FILE) exec php php artisan route:cache
	docker-compose -f $(COMPOSE_FILE) exec php php artisan view:cache
	make npm-build

clear-cache: ## Limpiar toda la cache
	docker-compose -f $(COMPOSE_FILE) exec php php artisan config:clear
	docker-compose -f $(COMPOSE_FILE) exec php php artisan route:clear
	docker-compose -f $(COMPOSE_FILE) exec php php artisan view:clear
	docker-compose -f $(COMPOSE_FILE) exec php php artisan cache:clear

# === COMANDOS DE TESTING ===
test: ## Ejecutar tests
	docker-compose -f $(COMPOSE_FILE) exec php php artisan test

test-coverage: ## Ejecutar tests con coverage
	docker-compose -f $(COMPOSE_FILE) exec php php artisan test --coverage

# === COMANDOS DE PRODUCCIÓN ===
deploy-prod: ## Desplegar en producción
	@echo "$(YELLOW)Desplegando en producción...$(NC)"
	@if [ -f "./env.production" ]; then \
		cp ./env.production ./app/.env; \
	fi
	make build
	make down
	make up
	make optimize
	@echo "$(GREEN)Despliegue completado!$(NC)"

backup: ## Crear backup de la aplicación
	@echo "$(YELLOW)Creando backup...$(NC)"
	mkdir -p backups
	tar -czf backups/sboil-backup-$(shell date +%Y%m%d-%H%M%S).tar.gz app/ docker/ --exclude=app/node_modules --exclude=app/vendor
	@echo "$(GREEN)Backup creado en directorio backups/$(NC)"

# === COMANDOS DE LIMPIEZA ===
clean: ## Limpiar contenedores, imágenes y volúmenes no utilizados
	@echo "$(YELLOW)Limpiando recursos Docker...$(NC)"
	docker-compose -f $(COMPOSE_FILE) down -v
	docker system prune -f
	docker volume prune -f

clean-all: ## Limpiar todo (incluyendo imágenes)
	@echo "$(RED)⚠️  ADVERTENCIA: Esto eliminará todas las imágenes Docker no utilizadas$(NC)"
	@read -p "¿Estás seguro? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		make clean; \
		docker image prune -a -f; \
	fi

destroy: ## Eliminar COMPLETAMENTE todo lo relacionado con la aplicación (SOLO este proyecto)
	@echo "$(RED)⚠️  ADVERTENCIA: Esto eliminará SOLO los recursos del proyecto $(BASE_APP_NAME)$(NC)"
	@echo "$(RED)⚠️  Incluyendo: contenedores, imágenes, volúmenes y red de aplicación$(NC)"
	@echo "$(GREEN)✓ Se preservarán TODAS las otras redes y recursos de Docker$(NC)"
	@read -p "¿Estás seguro? Esta acción NO se puede deshacer [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "$(YELLOW)Ejecutando script de destrucción completa...$(NC)"; \
		./scripts/destroy-app.sh $(BASE_APP_NAME); \
	else \
		echo "$(GREEN)Operación cancelada$(NC)"; \
	fi

# === COMANDOS DE INFORMACIÓN ===
info: ## Mostrar información del entorno
	@echo "$(BLUE)=== INFORMACIÓN DEL ENTORNO ===$(NC)"
	@echo "$(YELLOW)Puertos no expuestos - usar Nginx Proxy Manager$(NC)"
	@echo "$(GREEN)Contenedores disponibles:$(NC)"
	@echo "  - sboil_nginx (puerto interno 80)"
	@echo "  - sboil_reverb (puerto interno 8080)"
	@echo "  - sboil_node (puerto interno 5173)"
	@echo "  - sboil_redis (puerto interno 6379)"
	@echo ""
	@echo "$(BLUE)=== ESTADO DE CONTENEDORES ===$(NC)"
	@make status

# === COMANDOS DE DESARROLLO ===
dev: ## Iniciar entorno de desarrollo
	@echo "$(YELLOW)Iniciando entorno de desarrollo...$(NC)"
	make up
	make npm-install
	@echo "$(GREEN)Entorno de desarrollo listo!$(NC)"
	@echo "$(BLUE)Comandos útiles:$(NC)"
	@echo "  - make logs: Ver logs en tiempo real"
	@echo "  - make shell: Acceder al contenedor PHP"
	@echo "  - make artisan cmd=\"route:list\": Ejecutar comandos artisan"

watch: ## Iniciar watchers para desarrollo
	@echo "$(YELLOW)Iniciando watchers...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec -d $(NODE_CONTAINER) npm run watch

# === COMANDOS DE REVERB ===
reverb-restart: ## Reiniciar servidor Reverb
	docker-compose -f $(COMPOSE_FILE) restart $(BASE_APP_NAME)_reverb

reverb-logs: ## Ver logs de Reverb
	docker-compose -f $(COMPOSE_FILE) logs -f $(BASE_APP_NAME)_reverb

# === COMANDOS DE QUEUE ===
queue-restart: ## Reiniciar workers de queue
	docker-compose -f $(COMPOSE_FILE) restart $(BASE_APP_NAME)_queue

queue-logs: ## Ver logs de queue
	docker-compose -f $(COMPOSE_FILE) logs -f $(BASE_APP_NAME)_queue

# === COMANDOS DE RED ===
network-info: ## Mostrar información de red
	@echo "$(BLUE)=== INFORMACIÓN DE RED ===$(NC)"
	@if docker network ls | grep -q "red_general"; then \
		echo "$(GREEN)✓ Red externa 'red_general' encontrada$(NC)"; \
	else \
		echo "$(RED)✗ Red externa 'red_general' NO encontrada$(NC)"; \
		echo "$(YELLOW)Crear con: docker network create red_general$(NC)"; \
	fi
	@echo ""
	@docker network ls | grep -E "(red_general|$(BASE_APP_NAME))" || echo "$(YELLOW)No se encontraron redes relacionadas$(NC)"
	@echo ""
	@echo "$(GREEN)Red de aplicación:$(NC) $(BASE_APP_NAME)_app_network"
	@echo "$(GREEN)Red externa:$(NC) red_general"

check-network: ## Verificar si la red externa existe
	@if docker network ls | grep -q "red_general"; then \
		echo "$(GREEN)✓ Red 'red_general' está disponible$(NC)"; \
	else \
		echo "$(RED)✗ Red 'red_general' no existe$(NC)"; \
		echo "$(YELLOW)Créala con: docker network create red_general$(NC)"; \
		exit 1; \
	fi

recreate-networks: ## Recrear redes importantes (red_general, webodm_default, cloudflare_default)
	@echo "$(YELLOW)Recreando redes importantes...$(NC)"
	./scripts/recreate-networks.sh

# === COMANDOS DE CONFIGURACIÓN ===
rename: ## Cambiar nombre de la aplicación (usar: make rename name="nuevo-nombre")
	@if [ -z "$(name)" ]; then \
		echo "$(RED)Error: Debes proporcionar un nombre$(NC)"; \
		echo "$(YELLOW)Uso: make rename name=\"nuevo-nombre\"$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Cambiando nombre de aplicación a: $(name)$(NC)"
	./scripts/update-app-name.sh $(name)

copy-template: ## Copiar plantilla a nueva aplicación (usar: make copy-template name="nueva-app" dir="../")
	@if [ -z "$(name)" ]; then \
		echo "$(RED)Error: Debes proporcionar un nombre$(NC)"; \
		echo "$(YELLOW)Uso: make copy-template name=\"nueva-app\" dir=\"../\"$(NC)"; \
		exit 1; \
	fi
	@DIR=$${dir:-"../"}; \
	echo "$(YELLOW)Copiando plantilla a: $$DIR/$(name)$(NC)"; \
	./scripts/copy-template.sh $(name) $$DIR
