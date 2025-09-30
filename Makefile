# Makefile para aplicación Laravel unificada
# Uso: make [comando]

.PHONY: help build up down restart logs shell composer artisan npm install-laravel fresh migrate seed optimize test backup restore deploy clean

# Variables de configuración
BASE_APP_NAME=sboil
COMPOSE_FILE=docker-compose.yml
APP_CONTAINER=$(BASE_APP_NAME)_app

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
build: ## Construir la imagen unificada
	@echo "$(YELLOW)Construyendo imagen unificada...$(NC)"
	docker-compose -f $(COMPOSE_FILE) build

up: ## Levantar la aplicación
	@echo "$(YELLOW)Iniciando aplicación...$(NC)"
	docker-compose -f $(COMPOSE_FILE) up -d
	@echo "$(GREEN)Aplicación iniciada correctamente$(NC)"
	@echo "$(BLUE)Configura Nginx Proxy Manager para acceder a:$(NC)"
	@echo "$(GREEN)  - Aplicación: $(BASE_APP_NAME) (puerto 80)$(NC)"
	@echo "$(GREEN)  - Vite Dev: $(BASE_APP_NAME) (puerto 5173)$(NC)"

down: ## Detener la aplicación
	@echo "$(YELLOW)Deteniendo aplicación...$(NC)"
	docker-compose -f $(COMPOSE_FILE) down

restart: ## Reiniciar la aplicación
	@echo "$(YELLOW)Reiniciando aplicación...$(NC)"
	docker-compose -f $(COMPOSE_FILE) restart

# === COMANDOS DE MONITOREO ===
logs: ## Ver logs de la aplicación
	docker-compose -f $(COMPOSE_FILE) logs -f app

redis-shell: ## Acceder al shell de Redis (dentro del contenedor unificado)
	docker-compose -f $(COMPOSE_FILE) exec app redis-cli

# === COMANDOS DE ZEROTIER ===
zerotier-status: ## Ver estado de ZeroTier
	docker-compose -f $(COMPOSE_FILE) exec app zerotier-cli status

zerotier-join: ## Unirse a red ZeroTier (usar: make zerotier-join network="NETWORK_ID")
	docker-compose -f $(COMPOSE_FILE) exec app zerotier-cli join $(network)

zerotier-leave: ## Salir de red ZeroTier (usar: make zerotier-leave network="NETWORK_ID")
	docker-compose -f $(COMPOSE_FILE) exec app zerotier-cli leave $(network)

zerotier-networks: ## Listar redes ZeroTier
	docker-compose -f $(COMPOSE_FILE) exec app zerotier-cli listnetworks

zerotier-info: ## Ver información de ZeroTier
	docker-compose -f $(COMPOSE_FILE) exec app zerotier-cli info

status: ## Ver estado de los contenedores
	docker-compose -f $(COMPOSE_FILE) ps

# === SHELL DE CONTENEDOR ===
shell: ## Acceder al shell del contenedor
	docker-compose -f $(COMPOSE_FILE) exec app bash

# === COMANDOS DE PHP/LARAVEL ===
composer: ## Ejecutar comando composer (usar: make composer cmd="install")
	docker-compose -f $(COMPOSE_FILE) exec app composer $(cmd)

artisan: ## Ejecutar comando artisan (usar: make artisan cmd="migrate")
	docker-compose -f $(COMPOSE_FILE) exec app php artisan $(cmd)

# === ALIAS DINÁMICO DE ARTISAN ===
la: ## Ejecutar comando artisan dinámico (usar: make la cmd="migrate")
	docker-compose -f $(COMPOSE_FILE) exec app php artisan $(cmd)

# === ALIAS DE ARTISAN COMUNES ===
migrate: ## Ejecutar migraciones
	docker-compose -f $(COMPOSE_FILE) exec app php artisan migrate

migrate-fresh: ## Ejecutar migraciones desde cero
	docker-compose -f $(COMPOSE_FILE) exec app php artisan migrate:fresh

migrate-fresh-seed: ## Ejecutar migraciones desde cero y seeders
	docker-compose -f $(COMPOSE_FILE) exec app php artisan migrate:fresh --seed

seed: ## Ejecutar seeders
	docker-compose -f $(COMPOSE_FILE) exec app php artisan db:seed

migrate-seed: ## Ejecutar migraciones y seeders
	docker-compose -f $(COMPOSE_FILE) exec app php artisan migrate:fresh --seed

key: ## Generar clave de aplicación
	docker-compose -f $(COMPOSE_FILE) exec app php artisan key:generate

cache: ## Limpiar cache
	docker-compose -f $(COMPOSE_FILE) exec app php artisan cache:clear

config: ## Limpiar cache de configuración
	docker-compose -f $(COMPOSE_FILE) exec app php artisan config:clear

route: ## Limpiar cache de rutas
	docker-compose -f $(COMPOSE_FILE) exec app php artisan route:clear

view: ## Limpiar cache de vistas
	docker-compose -f $(COMPOSE_FILE) exec app php artisan view:clear

tinker: ## Abrir Tinker
	docker-compose -f $(COMPOSE_FILE) exec app php artisan tinker

test: ## Ejecutar tests
	docker-compose -f $(COMPOSE_FILE) exec app php artisan test

serve: ## Servir aplicación (solo para desarrollo local)
	docker-compose -f $(COMPOSE_FILE) exec app php artisan serve --host=0.0.0.0 --port=8000

# === COMANDOS DE NODE ===
npm: ## Ejecutar comando npm (usar: make npm cmd="install")
	docker-compose -f $(COMPOSE_FILE) exec app npm $(cmd)

npm-install: ## Instalar dependencias npm
	docker-compose -f $(COMPOSE_FILE) exec app npm install

npm-dev: ## Ejecutar npm run dev
	docker-compose -f $(COMPOSE_FILE) exec app npm run dev

npm-build: ## Ejecutar npm run build
	docker-compose -f $(COMPOSE_FILE) exec app npm run build

# === INSTALACIÓN Y CONFIGURACIÓN ===
clean-app: ## Limpiar directorio app para nueva instalación
	@echo "$(YELLOW)Limpiando directorio app...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec app sh -c "rm -rf /var/www/html/* /var/www/html/.* 2>/dev/null || true"

install-laravel: ## Instalar Laravel
	@echo "$(YELLOW)Instalando Laravel...$(NC)"
	make clean-app
	docker-compose -f $(COMPOSE_FILE) exec app composer create-project laravel/laravel . --remove-vcs
	@echo "$(GREEN)Laravel instalado correctamente!$(NC)"

install-reverb: ## Instalar Laravel Reverb
	@echo "$(YELLOW)Instalando Laravel Reverb...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec app php artisan install:broadcasting
	@echo "$(GREEN)Laravel Reverb instalado correctamente!$(NC)"
	@echo "$(YELLOW)Nota: Configura manualmente el archivo .env para Reverb$(NC)"

install-livewire: ## Instalar Laravel Livewire
	@echo "$(YELLOW)Instalando Laravel Livewire...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec app composer require livewire/livewire
	docker-compose -f $(COMPOSE_FILE) exec app php artisan livewire:publish --config
	@echo "$(GREEN)Laravel Livewire instalado correctamente!$(NC)"

setup-env: ## Configurar archivo .env
	@if [ ! -f "./app/.env" ]; then \
		echo "$(YELLOW)Copiando archivo .env...$(NC)"; \
		docker-compose -f $(COMPOSE_FILE) exec app cp .env.example .env; \
	fi
	docker-compose -f $(COMPOSE_FILE) exec app php artisan key:generate

fresh: ## Instalación completa desde cero
	@echo "$(YELLOW)Instalación completa...$(NC)"
	make build
	make up
	sleep 10
	make install-laravel
	make setup-env
	make migrate
	make npm-install
	@echo "$(GREEN)Instalación completada!$(NC)"

# === COMANDOS DE BASE DE DATOS ===
# (Los comandos migrate, migrate-fresh, seed ya están definidos en la sección de ALIAS DE ARTISAN COMUNES)

# === COMANDOS DE OPTIMIZACIÓN ===
optimize: ## Optimizar aplicación para producción
	docker-compose -f $(COMPOSE_FILE) exec app php artisan config:cache
	docker-compose -f $(COMPOSE_FILE) exec app php artisan route:cache
	docker-compose -f $(COMPOSE_FILE) exec app php artisan view:cache
	make npm-build

clear-cache: ## Limpiar toda la cache
	docker-compose -f $(COMPOSE_FILE) exec app php artisan config:clear
	docker-compose -f $(COMPOSE_FILE) exec app php artisan route:clear
	docker-compose -f $(COMPOSE_FILE) exec app php artisan view:clear
	docker-compose -f $(COMPOSE_FILE) exec app php artisan cache:clear

# === COMANDOS DE TESTING ===
# test: ## Ejecutar tests (ya definido en ALIAS DE ARTISAN COMUNES)

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

destroy: ## Eliminar COMPLETAMENTE todo lo relacionado con la aplicación
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
	@echo "$(GREEN)Contenedores disponibles:$(NC)"
	@echo "  - sboil_app (puerto 80, 5173)"
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
	@echo "  - make shell: Acceder al contenedor"
	@echo "  - make artisan cmd=\"route:list\": Ejecutar comandos artisan"
