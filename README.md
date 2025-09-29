# SBoil - Plantilla Laravel con Docker y WebSockets

Una plantilla completa de Docker para desarrollar y desplegar aplicaciones Laravel con Laravel Reverb para WebSockets en tiempo real. **Totalmente optimizada y lista para usar con Nginx Proxy Manager.**

## 🚀 Características

- **PHP 8.4** con PHP-FPM optimizado y configuración corregida
- **Nginx** como servidor web (SSL comentado para Nginx Proxy Manager)
- **Node.js 22** para Vite y desarrollo frontend con permisos corregidos
- **Laravel Reverb** para WebSockets en tiempo real
- **Redis** para cache, sesiones y colas
- **Queue Workers** para procesamiento en background
- **Scheduler** para tareas programadas (cron)
- **Estructura modular** fácil de replicar con script interactivo
- **Scripts de automatización** para desarrollo, producción y creación de nuevas apps
- **Makefile** con comandos abreviados y limpieza automática
- **Compatible con Nginx Proxy Manager** (puertos no expuestos)

## ✅ Estado del Proyecto

**🎯 TOTALMENTE FUNCIONAL Y CORREGIDO**

Todas las configuraciones han sido optimizadas y probadas. La secuencia de instalación funciona perfectamente:

```bash
# Copia la carpeta, cambia al directorio y ejecuta:
make build
make up  
make install-laravel
```

**Todos los contenedores funcionan sin errores** ✅

## 📋 Requisitos

- Docker y Docker Compose
- Red Docker externa llamada `red_general` (debe existir previamente)
- Make (opcional, pero recomendado)
- **Nginx Proxy Manager** (recomendado para acceso web)

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

### Opción 1: Crear nueva aplicación desde plantilla existente 🎯

```bash
# Si ya tienes la plantilla sboil/, crea una nueva app:
cd sboil/
./scripts/copy-template.sh    # Script interactivo
# Te pregunta el nombre y crea la nueva app al mismo nivel

cd ../mi-nueva-app/
make fresh                    # Instalación automática
```

### Opción 2: Instalación manual completa

```bash
# Clonar o copiar esta plantilla
git clone <repo> mi-nueva-app
cd mi-nueva-app

# Ejecutar instalación completa
make fresh
```

### Opción 3: Instalación manual paso a paso (RECOMENDADO)

```bash
# 1. Construir imágenes
make build

# 2. Iniciar contenedores
make up

# 3. Instalar Laravel (con limpieza automática)
make install-laravel

# 4. Configurar entorno (opcional)
make setup-env

# 5. Instalar Laravel Reverb (opcional)
make install-reverb

# 6. Instalar dependencias npm (opcional)
make npm-install
```

### Opción 4: Usando script de inicialización

```bash
# Ejecutar instalación completa
./scripts/init.sh
```

## 🔧 Correcciones Implementadas

### ✅ Problemas Resueltos Completamente

#### 1. **PHP-FPM Configuration**
- **Corregido:** Problemas de permisos con logs de PHP-FPM
- **Solución:** Comentadas configuraciones problemáticas de `slowlog`
- **Estado:** ✅ Funcional sin errores

#### 2. **Nginx SSL Configuration**  
- **Corregido:** Errores de certificados SSL y sintaxis HTTP/2 deprecada
- **Solución:** Configuración HTTPS completamente comentada para desarrollo
- **Beneficio:** Compatible con Nginx Proxy Manager
- **Estado:** ✅ Funcional sin errores SSL

#### 3. **Node.js Permissions**
- **Corregido:** Problemas de permisos con `node_modules`
- **Solución:** Configuración optimizada de usuarios y eliminación de volumen problemático
- **Estado:** ✅ Vite dev server funcionando correctamente

#### 4. **Docker Compose Optimization**
- **Corregido:** Volúmenes problemáticos y puertos expuestos
- **Solución:** Eliminado `node_modules_data` y comentados puertos para proxy
- **Estado:** ✅ Totalmente compatible con Nginx Proxy Manager

#### 5. **Makefile Commands**
- **Corregido:** Referencias incorrectas a contenedores y comandos interactivos
- **Solución:** Comandos optimizados y limpieza automática
- **Nuevo:** Comando `clean-app` para limpiar antes de instalar Laravel
- **Estado:** ✅ Todos los comandos funcionan perfectamente

## 🌐 Configuración con Nginx Proxy Manager

### Puertos Internos (NO expuestos)

| Servicio | Puerto Interno | Descripción |
|----------|---------------|-------------|
| **Aplicación web** | 80 | Laravel app (HTTP) |
| **WebSockets** | 8080 | Laravel Reverb |
| **Vite dev server** | 5173 | Hot reload frontend |
| **Redis** | 6379 | Cache/Sessions (interno) |

### Configurar en Nginx Proxy Manager

1. **Para la aplicación web:**
   - **Scheme:** `http`
   - **Forward Hostname/IP:** `nombre_contenedor_nginx`
   - **Forward Port:** `80`

2. **Para WebSockets:**
   - **Scheme:** `http`
   - **Forward Hostname/IP:** `nombre_contenedor_reverb`  
   - **Forward Port:** `8080`
   - **WebSockets Support:** ✅ Habilitado

## 🖥️ Comandos de Desarrollo

### Comandos principales

```bash
# Ver todos los comandos disponibles
make help

# Iniciar entorno de desarrollo (sin Vite)
make dev

# Iniciar entorno de desarrollo con Vite
make dev-with-vite

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

### Comandos de Vite (Desarrollo Frontend)

```bash
# Ver logs de Vite
make logs-node

# Acceder al shell del contenedor Node
make node-shell

# Iniciar watchers para desarrollo
make watch

# Comandos npm específicos para Vite
make npm-dev    # npm run dev
make npm-build  # npm run build
make npm-watch  # npm run watch
```

**Nota:** Vite solo está disponible cuando usas `make dev-with-vite` o cuando el contenedor `node` está ejecutándose.

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

### Comandos de limpieza

```bash
# Limpiar directorio app para nueva instalación
make clean-app

# Limpiar recursos Docker no utilizados
make clean

# Limpiar todo (incluyendo imágenes)
make clean-all
```

## 📁 Estructura del Proyecto

```
sboil/
├── app/                    # Código de Laravel (se crea al instalar)
├── docker/                 # Configuraciones Docker
│   ├── nginx/             # Configuración Nginx (SSL comentado)
│   │   ├── Dockerfile
│   │   ├── nginx.conf
│   │   └── conf.d/
│   │       ├── laravel.conf    # Configuración principal
│   │       └── vite-dev.conf    # Configuración Vite (modular)
│   ├── php/               # PHP 8.4 + extensiones (permisos corregidos)
│   │   ├── Dockerfile
│   │   └── conf.d/
│   │       ├── custom.ini
│   │       └── php-fpm.conf
│   └── node/              # Node.js 22 para Vite (permisos corregidos)
│       └── Dockerfile
├── scripts/               # Scripts de automatización
│   ├── init.sh           # Instalación inicial
│   ├── deploy.sh         # Despliegue producción
│   └── copy-template.sh  # Copiar plantilla
├── docker-compose.yml    # Desarrollo (puertos comentados)
├── docker-compose.production.yml  # Producción (puertos comentados)
├── Makefile             # Comandos abreviados (corregidos)
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

### Configuración de Vite

La plantilla incluye soporte modular para Vite con configuración automática:

#### **Desarrollo con Vite:**
```bash
# Iniciar con Vite habilitado
make dev-with-vite
```

#### **Desarrollo sin Vite:**
```bash
# Iniciar solo Laravel (sin Node.js/Vite)
make dev
```

#### **Configuración automática:**
- **Nginx** se configura automáticamente para redirigir assets de Vite
- **Solo se activa** cuando el contenedor `node` está presente
- **No afecta** proyectos que no usen Vite
- **Configuración modular** en `docker/nginx/conf.d/vite-dev.conf`

#### **Para Nginx Proxy Manager:**
- Solo necesitas configurar **un host** apuntando a `sboil_nginx:80`
- Nginx interno redirige automáticamente las peticiones de Vite al contenedor Node

### SSL/HTTPS

**Para desarrollo:** La configuración SSL está completamente comentada para evitar conflictos con Nginx Proxy Manager.

**Para producción:** Si necesitas SSL directo (sin proxy), descomenta la configuración HTTPS en `docker/nginx/conf.d/laravel.conf` y configura tus certificados.

## 🚀 Despliegue en Producción

### Con Nginx Proxy Manager (Recomendado)

```bash
# 1. Configurar entorno de producción
cp env.production app/.env

# 2. Usar docker-compose de producción
docker-compose -f docker-compose.production.yml up -d

# 3. Optimizar para producción
make optimize
```

### Despliegue automático

```bash
# Desplegar en producción
./scripts/deploy.sh production

# O usando Make
make deploy-prod
```

## 📋 Gestión de Aplicaciones

### Cambiar Nombre de la Aplicación Actual

```bash
# Usando make (recomendado)
make rename name="mi-nueva-app"

# O usando script directamente
./scripts/update-app-name.sh mi-nueva-app
```

### Crear Nueva Aplicación desde Plantilla

#### 🎯 Modo Interactivo (Recomendado)

```bash
# Script interactivo - te pregunta todo lo necesario
./scripts/copy-template.sh

# El script te preguntará:
# 🚀 Nombre de la nueva aplicación: mi-nueva-app
# 📁 Directorio destino (presiona Enter para '../'): [Enter]

# Resultado: crea la nueva app al mismo nivel que sboil/
# /Users/tu-usuario/Proyectos/php/aplicaciones/
# ├── sboil/           # 👈 Plantilla original
# └── mi-nueva-app/    # 👈 Nueva aplicación creada
```

#### ⚡ Modo Manual

```bash
# Usando make
make copy-template name="mi-nueva-app" dir="../"

# O usando script directamente con argumentos
./scripts/copy-template.sh mi-nueva-app ../

# Ir al nuevo directorio e inicializar
cd ../mi-nueva-app
make build && make up && make install-laravel
```

#### 📋 Resultado del Script

El script automáticamente:
- ✅ **Copia** toda la estructura Docker y configuraciones
- ✅ **Personaliza** nombres en todos los archivos
- ✅ **Actualiza** docker-compose.yml, Makefile, .app-config
- ✅ **Crea** README.md personalizado para la nueva app
- ✅ **Preserva** README original como README-original.md
- ✅ **Configura** permisos ejecutables en scripts
- ✅ **Genera** .gitignore apropiado

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

### Contenedores se reinician constantemente

**✅ PROBLEMA YA RESUELTO:** Todas las configuraciones que causaban reinicios han sido corregidas.

Si experimentas reinicios:

```bash
# Ver logs específicos
make logs-php
make logs-nginx

# Verificar que Laravel esté instalado
ls -la app/

# Si app/ está vacío, instalar Laravel
make install-laravel
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

**✅ PROBLEMA YA RESUELTO:** Todas las configuraciones de permisos han sido corregidas.

Si experimentas problemas de permisos:

```bash
# Acceder al contenedor y verificar permisos
make shell
chown -R www:www /var/www/html/storage
chown -R www:www /var/www/html/bootstrap/cache
```

## 🧹 Limpieza

### Limpieza básica

```bash
# Limpiar directorio app para reinstalar Laravel
make clean-app

# Limpiar recursos Docker no utilizados
make clean

# Limpiar todo (incluyendo imágenes)
make clean-all

# Crear backup antes de limpiar
make backup
```

### Limpieza completa del proyecto

```bash
# ELIMINAR COMPLETAMENTE todo lo relacionado con la aplicación actual
# ⚠️ PRESERVA TODAS las otras redes y proyectos Docker
make destroy

# O usando el script independiente (detecta automáticamente el nombre)
./scripts/destroy-app.sh

# O especificando el nombre manualmente
./scripts/destroy-app.sh mi-app-name
```

## 🎯 Mejoras Técnicas Recientes

### ✅ Configuración PHP-FPM Optimizada

**Problemas resueltos:**
- Errores de permisos con logs de slowlog
- Configuración de request_slowlog_timeout problemática

**Mejoras aplicadas:**
- Logs de slowlog comentados para evitar errores de permisos
- Configuración optimizada para desarrollo
- PHP-FPM funciona sin errores

### ✅ Nginx SSL Configuration Actualizada

**Problemas resueltos:**
- Errores de certificados SSL no existentes
- Sintaxis HTTP/2 deprecada
- Conflictos con Nginx Proxy Manager

**Mejoras aplicadas:**
- Configuración HTTPS completamente comentada para desarrollo
- Compatible con Nginx Proxy Manager
- Puertos no expuestos en desarrollo y producción

### ✅ Node.js Permissions Corregidos

**Problemas resueltos:**
- Conflictos de permisos con node_modules
- Volumen anónimo problemático

**Mejoras aplicadas:**
- Usuario `node` nativo optimizado
- Eliminado volumen separado problemático
- Vite dev server funcionando correctamente

### ✅ Makefile Commands Optimizados

**Problemas resueltos:**
- Referencias incorrectas a `$(APP_CONTAINER)`
- Comandos interactivos que fallaban
- Directorio app no limpio para nuevas instalaciones

**Mejoras aplicadas:**
- Todas las referencias corregidas a `php`
- Comando `clean-app` para limpieza automática
- `install-laravel` con limpieza previa
- `install-reverb` simplificado

### ✅ Docker Compose Optimization

**Mejoras aplicadas:**
- Volumen `node_modules_data` eliminado (era problemático)
- Puertos comentados para Nginx Proxy Manager
- Dependencias optimizadas entre contenedores
- Configuración lista para producción

## 📊 Estado de Contenedores

### ✅ Todos Funcionando Correctamente

| Contenedor | Estado | Puerto | Descripción |
|------------|--------|--------|-------------|
| **sboil_php** | ✅ Up | 9000 | PHP-FPM (interno) |
| **sboil_nginx** | ✅ Up | 80, 443 | Servidor web |
| **sboil_node** | ✅ Up | 5173, 3000 | Vite dev server |
| **sboil_redis** | ✅ Up | 6379 | Cache/Sessions |
| **sboil_reverb** | ✅ Up | 9000 | WebSockets |
| **sboil_queue** | ✅ Up | 9000 | Queue worker |
| **sboil_scheduler** | ✅ Up | 9000 | Cron jobs |

### ✅ Soporte Vite Modular Implementado

**Nuevas funcionalidades:**

- **Configuración modular** de Vite que no afecta otros proyectos
- **Comandos específicos** para desarrollo con/sin Vite
- **Proxy automático** de Nginx para assets de Vite
- **Compatibilidad total** con Nginx Proxy Manager
- **Configuración segura** que se activa solo cuando es necesario

**Archivos agregados:**
- `docker/nginx/conf.d/vite-dev.conf` - Configuración modular de Vite
- Comandos `make dev-with-vite` y `make dev` para diferentes tipos de desarrollo

**Beneficios:**
- ✅ **Reutilizable** - La plantilla funciona para cualquier proyecto
- ✅ **Segura** - No afecta proyectos que no usen Vite  
- ✅ **Flexible** - Se puede activar/desactivar fácilmente
- ✅ **Mantenible** - Configuración separada y clara

## 📚 Documentación Adicional

- [Laravel Documentation](https://laravel.com/docs)
- [Laravel Reverb Documentation](https://laravel.com/docs/broadcasting#reverb)
- [Docker Documentation](https://docs.docker.com/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Nginx Proxy Manager](https://nginxproxymanager.com/)

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

## 🏆 Garantía de Funcionamiento

**Este proyecto ha sido completamente probado y corregido. La secuencia de instalación funciona garantizada:**

```bash
# Copia la carpeta y ejecuta:
make build
make up
make install-laravel
```

**✅ Todos los contenedores funcionan sin errores**  
**✅ Compatible con Nginx Proxy Manager**  
**✅ Listo para desarrollo y producción**

**¡Happy coding! 🎉**
