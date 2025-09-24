# SBoil - Plantilla Laravel con Docker y WebSockets

Una plantilla completa de Docker para desarrollar y desplegar aplicaciones Laravel con Laravel Reverb para WebSockets en tiempo real.

## 🚀 Características

- **PHP 8.4** con PHP-FPM optimizado
- **Nginx** como servidor web con configuración SSL
- **Node.js 22** para Vite y desarrollo frontend
- **Laravel Reverb** para WebSockets en tiempo real
- **Redis** para cache, sesiones y colas
- **Queue Workers** para procesamiento en background
- **Scheduler** para tareas programadas (cron)
- **Estructura modular** fácil de replicar
- **Scripts de automatización** para desarrollo y producción
- **Makefile** con comandos abreviados

## 📋 Requisitos

- Docker y Docker Compose
- Red Docker externa llamada `red_general` (debe existir previamente)
- Make (opcional, pero recomendado)

### Verificar Red Externa

```bash
# Verificar si la red existe
make check-network

# Ver información de redes
make network-info

# Si la red no existe, créala
docker network create red_general
```

## 🛠️ Instalación Rápida

### Opción 1: Instalación automática completa

```bash
# Clonar o copiar esta plantilla
git clone <repo> sboil
cd sboil

# Ejecutar instalación completa
./scripts/init.sh

# O usando Make
make fresh
```

### Opción 2: Instalación manual paso a paso

```bash
# 1. Construir imágenes
make build

# 2. Iniciar contenedores
make up

# 3. Instalar Laravel
make install-laravel

# 4. Configurar entorno
make setup-env

# 5. Instalar Laravel Reverb
make install-reverb

# 6. Instalar dependencias npm
make npm-install
```

## 🖥️ Comandos de Desarrollo

### Comandos principales

```bash
# Ver todos los comandos disponibles
make help

# Iniciar entorno de desarrollo
make dev

# Ver logs en tiempo real
make logs

# Acceder al contenedor PHP
make shell

# Estado de contenedores
make status

# Reiniciar servicios
make restart

# ELIMINAR COMPLETAMENTE el proyecto (preserva red_general)
make destroy
```

### Comandos de Laravel

```bash
# Ejecutar comando artisan
make artisan cmd="migrate"
make artisan cmd="make:controller UserController"

# Migraciones
make migrate
make migrate-fresh
make migrate-seed

# Cache
make clear-cache
make optimize

# Tests
make test
```

### Comandos de Node.js

```bash
# Instalar dependencias
make npm-install

# Servidor de desarrollo Vite
make npm-dev

# Build para producción
make npm-build

# Ejecutar comando npm personalizado
make npm cmd="install lodash"
```

### Comandos de servicios

```bash
# Logs específicos
make logs-php
make logs-nginx
make logs-reverb
make logs-queue

# Reiniciar servicios específicos
make reverb-restart
make queue-restart

# Acceso a shells
make php-shell
make node-shell
make nginx-shell
make redis-shell
```

## 🌐 Puertos y Acceso

| Servicio | Puerto | URL | Descripción |
|----------|--------|-----|-------------|
| Aplicación web | 80/443 | http://localhost | Laravel app |
| WebSockets | 8080 | ws://localhost:8080 | Laravel Reverb |
| Vite dev server | 5173 | http://localhost:5173 | Hot reload |
| Redis | 6379 | localhost:6379 | Cache/Sessions |

## 📁 Estructura del Proyecto

```
sboil/
├── app/                    # Código de Laravel (se crea al instalar)
├── docker/                 # Configuraciones Docker
│   ├── nginx/             # Configuración Nginx + SSL
│   │   ├── Dockerfile
│   │   ├── nginx.conf
│   │   └── conf.d/
│   ├── php/               # PHP 8.4 + extensiones
│   │   ├── Dockerfile
│   │   └── conf.d/
│   └── node/              # Node.js 22 para Vite
│       └── Dockerfile
├── scripts/               # Scripts de automatización
│   ├── init.sh           # Instalación inicial
│   ├── deploy.sh         # Despliegue producción
│   └── copy-template.sh  # Copiar plantilla
├── docker-compose.yml    # Orquestación de servicios
├── Makefile             # Comandos abreviados
├── env.example          # Variables de entorno desarrollo
├── env.production       # Variables de entorno producción
└── README.md           # Esta documentación
```

## 🔧 Configuración

### Variables de Entorno

Copia y configura los archivos de entorno según tu necesidad:

```bash
# Para desarrollo
cp env.example app/.env

# Para producción
cp env.production app/.env
```

### Red Externa

La aplicación se conecta a una red Docker externa llamada `red_general` donde debe estar tu base de datos:

```bash
# Crear la red (si no existe)
docker network create red_general

# Verificar la red
docker network ls | grep red_general
```

### SSL/HTTPS

La configuración incluye certificados SSL auto-firmados para desarrollo. Para producción, reemplaza los certificados en `docker/nginx/ssl/`.

## 🚀 Despliegue en Producción

### Despliegue automático

```bash
# Desplegar en producción
./scripts/deploy.sh production

# O usando Make
make deploy-prod
```

### Despliegue manual

```bash
# 1. Configurar entorno de producción
cp env.production app/.env

# 2. Construir y desplegar
make build
make down
make up

# 3. Optimizar para producción
make optimize
```

### Nginx Proxy Manager

Esta configuración es compatible con Nginx Proxy Manager tanto en desarrollo como en producción. Configura tu proxy para apuntar a:

- **HTTP**: Puerto 80 del contenedor
- **WebSockets**: Puerto 8080 del contenedor

## 🔧 Mejoras Técnicas Recientes

### ✅ Corrección de Volúmenes Docker

**Problema solucionado:** Se eliminó el volumen anónimo que causaba problemas de gestión.

**Antes:**
```yaml
volumes:
  - ./app:/var/www/html
  - /var/www/html/node_modules  # Volume anónimo problemático
```

**Después:**
```yaml
volumes:
  - ./app:/var/www/html
  - node_modules_data:/var/www/html/node_modules  # Volume nombrado
```

**Beneficios:**
- ✅ **Gestión mejorada:** El volumen tiene un nombre específico
- ✅ **Reutilización:** Se mantiene entre recreaciones de contenedores
- ✅ **Limpieza fácil:** Se puede eliminar específicamente
- ✅ **Mejor organización:** Fácil identificación en `docker volume ls`

### ✅ Nuevo Sistema de Limpieza Completa

Se agregó el comando `make destroy` que:
- 🔥 Elimina **TODO** lo relacionado con el proyecto
- 🛡️ **Preserva** la red `red_general`
- ⚡ Incluye confirmación de seguridad
- 📋 Muestra vista previa de lo que se eliminará

## 📋 Gestión de Aplicaciones

### Cambiar Nombre de la Aplicación Actual

```bash
# Usando make (recomendado)
make rename name="mi-nueva-app"

# O usando script directamente
./scripts/update-app-name.sh mi-nueva-app
```

### Crear Nueva Aplicación desde Plantilla

```bash
# Usando make (recomendado)
make copy-template name="mi-nueva-app" dir="../"

# O usando script directamente
./scripts/copy-template.sh mi-nueva-app /ruta/destino/

# Ir al nuevo directorio
cd /ruta/destino/mi-nueva-app

# Inicializar nueva aplicación
./scripts/init.sh mi-nueva-app
```

### Configuración Central

El nombre de la aplicación se gestiona desde el archivo `.app-config`:

```bash
# Ver configuración actual
cat .app-config

# La variable APP_NAME controla el nombre en todos los archivos
APP_NAME=sboil
```

## 🔍 Monitoreo y Logs

```bash
# Ver logs en tiempo real de todos los servicios
make logs

# Logs específicos
make logs-php      # Laravel/PHP-FPM
make logs-nginx    # Servidor web
make logs-reverb   # WebSockets
make logs-queue    # Cola de trabajos

# Estado de servicios
make status

# Información del entorno
make info
```

## 🧪 Testing

```bash
# Ejecutar tests
make test

# Tests con coverage
make test-coverage

# Acceder al contenedor para tests específicos
make shell
php artisan test --filter UserTest
```

## 🔧 Resolución de Problemas

### Contenedores no inician

```bash
# Verificar red externa primero
make check-network

# Verificar estado
make status

# Reconstruir imágenes
make build

# Ver logs de errores
make logs
```

### Red externa no encontrada

```bash
# Verificar si existe la red
make network-info

# Crear la red si no existe
docker network create red_general

# Verificar nuevamente
make check-network
```

### WebSockets no funcionan

```bash
# Verificar servicio Reverb
make logs-reverb

# Reiniciar Reverb
make reverb-restart

# Verificar configuración
make shell
php artisan config:show broadcasting
```

### Problemas de permisos

```bash
# Acceder al contenedor y verificar permisos
make shell
chown -R www:www /var/www/html/storage
chown -R www:www /var/www/html/bootstrap/cache
```

## 🧹 Limpieza

### Limpieza básica

```bash
# Limpiar recursos Docker no utilizados
make clean

# Limpiar todo (incluyendo imágenes)
make clean-all

# Crear backup antes de limpiar
make backup
```

### Limpieza completa del proyecto

```bash
# ELIMINAR COMPLETAMENTE todo lo relacionado con sboil
# ⚠️ PRESERVA la red 'red_general'
make destroy

# O usando el script independiente
./scripts/destroy-sboil.sh
```

#### ¿Qué elimina el comando `destroy`?

**✅ ELIMINA:**
- **Contenedores:** `sboil_php`, `sboil_nginx`, `sboil_node`, `sboil_reverb`, `sboil_queue`, `sboil_redis`, `sboil_scheduler`
- **Volúmenes:** `redis_data`, `node_modules_data`, `nginx_cache`
- **Imágenes:** Todas las imágenes construidas para el proyecto sboil
- **Red de aplicación:** `sboil_app_network`
- **Recursos huérfanos:** Containers, networks, volumes sin usar

**🛡️ PRESERVA:**
- **Red externa:** `red_general` (la mantiene intacta)
- **Otras aplicaciones:** No afecta otros proyectos Docker
- **Imágenes base:** nginx, php, node, redis (solo elimina las personalizadas)

**🚀 Características:**
- ✅ Confirmación de seguridad antes de ejecutar
- ✅ Vista previa de recursos que se eliminarán
- ✅ Limpieza completa y sistemática
- ✅ Preservación inteligente de `red_general`
- ✅ Feedback visual con colores
- ✅ Manejo de errores robusto

## 📚 Documentación Adicional

- [Laravel Documentation](https://laravel.com/docs)
- [Laravel Reverb Documentation](https://laravel.com/docs/broadcasting#reverb)
- [Docker Documentation](https://docs.docker.com/)
- [Nginx Documentation](https://nginx.org/en/docs/)

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 📞 Soporte

Para soporte o preguntas:

- Abrir un issue en GitHub
- Revisar la documentación: `make help`
- Verificar logs: `make logs`

---

**¡Happy coding! 🎉**
