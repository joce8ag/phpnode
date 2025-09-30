# Plantilla Laravel Simplificada

Una plantilla **ultra-simplificada** de Docker para desarrollar y desplegar aplicaciones Laravel con **una sola imagen y un solo contenedor**.

## 🚀 Características

- **Una sola imagen** con PHP 8.4 + Nginx + Node.js 22
- **Un solo contenedor** que ejecuta todos los servicios
- **Supervisor** para manejar múltiples procesos
- **Redis** para cache, sesiones y colas
- **Vite** integrado para desarrollo frontend
- **Queue Workers** y **Scheduler** automáticos
- **Laravel Reverb** para WebSockets (opcional)
- **Laravel Livewire** para componentes reactivos (opcional)
- **Compatible con Nginx Proxy Manager**
- **Estructura ultra-simple** y fácil de replicar

## ✅ Estado del Proyecto

**🎯 TOTALMENTE SIMPLIFICADO Y FUNCIONAL**

```bash
# Instalación en 3 comandos:
make build
make up  
make install-laravel
```

**Un solo contenedor ejecuta todo** ✅

## 📋 Requisitos

- Docker y Docker Compose
- Make (opcional, pero recomendado)
- **Nginx Proxy Manager** (recomendado para acceso web)

### Verificar Red Externa (opcional)

```bash
# Verificar si la red existe
docker network ls | grep red_general

# Si la red no existe, créala
docker network create red_general
```

## 🖥️ Comandos Principales

### **Comandos básicos:**

```bash
make help      # Ver todos los comandos disponibles
make up        # Iniciar la aplicación
make down      # Detener aplicación
make restart   # Reiniciar aplicación
make logs      # Ver logs en tiempo real
make shell     # Acceder al contenedor
make status    # Estado de contenedores
```

### **Comandos de Laravel:**

```bash
make artisan cmd="migrate"           # Ejecutar comando artisan
make migrate                        # Migraciones
make migrate-fresh                  # Migraciones desde cero
make migrate-seed                   # Migraciones + seeders
make clear-cache                    # Limpiar cache
make optimize                       # Optimizar aplicación
make test                          # Ejecutar tests
```

### **Comandos de Node.js/Vite:**

```bash
make npm-install    # Instalar dependencias
make npm-dev        # Servidor de desarrollo Vite
make npm-build      # Build para producción
make npm cmd="install lodash"  # Comando npm personalizado
```

### **Comandos de instalación:**

```bash
# Instalación básica
make fresh                    # Instalación completa desde cero
make install-laravel         # Solo instalar Laravel
make setup-env              # Configurar archivo .env

# Paquetes adicionales
make install-livewire       # Laravel Livewire (componentes reactivos)
make install-reverb         # Laravel Reverb (WebSockets)


### **Comandos de producción:**
```bash
make deploy-prod  # Desplegar en producción
make backup       # Crear backup
make optimize     # Optimizar para producción
```

### **Comandos de limpieza:**

```bash
make clean      # Limpiar recursos Docker
make clean-all  # Limpiar todo (incluyendo imágenes)
make destroy    # Eliminar completamente el proyecto
```

## 📁 Estructura del Proyecto

```
sboil/
├── app/                    # Código de Laravel (se crea al instalar)
├── docker/                 # Configuraciones Docker
│   ├── nginx/             # Configuración Nginx
│   │   ├── nginx.conf
│   │   └── conf.d/laravel.conf
│   ├── php/               # Configuración PHP
│   │   └── conf.d/
│   │       ├── custom.ini
│   │       └── php-fpm.conf
│   └── supervisor/        # Configuración Supervisor
│       └── supervisord.conf
├── scripts/               # Scripts de automatización
├── Dockerfile             # Imagen unificada
├── docker-compose.yml     # Un solo servicio
├── Makefile               # Comandos abreviados
├── env.example            # Variables de entorno
└── README.md              # Esta documentación
```

## 🔧 Configuración

### **Variables de Entorno**

```bash
# Para desarrollo
cp env.example app/.env

# Para producción
cp env.production app/.env
```

### **Red Externa (opcional)**

La aplicación se puede conectar a una red Docker externa llamada `red_general`:

```bash
# Crear la red (si no existe)
docker network create red_general

# Verificar la red
docker network ls | grep red_general
```

## 🚀 Despliegue en Producción

### **Con Nginx Proxy Manager (Recomendado)**

1. **Configurar NPM:**
   - **Domain**: `tu-dominio.com`
   - **Forward Hostname/IP**: `<nombreapp>_app` (o IP del contenedor)
   - **Forward Port**: `80`
   - **Websockets Support**: ✅ Activado

2. **Desplegar:**
```bash
make deploy-prod
```

## 🛠️ Desarrollo

### **Flujo de trabajo:**

```bash
# Desarrollo básico
make dev                  # Iniciar desarrollo
make shell               # Acceder al contenedor
make logs                # Ver logs
make artisan cmd="migrate"  # Comandos Laravel
```

### **Servicios incluidos:**

- **Nginx**: Servidor web (puerto 80)
- **PHP-FPM**: Procesador PHP
- **Node.js**: Vite dev server (puerto 5173)
- **Queue Worker**: Procesamiento de colas
- **Scheduler**: Tareas programadas (cron)
- **Redis**: Cache y sesiones

## 🔧 Personalización

### **Modificar servicios:**

Edita `docker/supervisor/supervisord.conf` para:
- Agregar nuevos servicios
- Modificar configuración de procesos
- Cambiar usuarios de ejecución

### **Modificar configuración:**

- **Nginx**: `docker/nginx/conf.d/laravel.conf`
- **PHP**: `docker/php/conf.d/custom.ini`
- **Supervisor**: `docker/supervisor/supervisord.conf`

### **Ejemplos de uso:**

```bash
# Aplicación básica
make fresh && make setup-env

# Con Livewire (componentes reactivos)
make fresh && make install-livewire && make setup-env

# Con Reverb (WebSockets)
make fresh && make install-reverb && make setup-env

# Aplicación completa
make fresh && make install-livewire && make install-reverb && make setup-env
```

## 📚 Documentación Adicional

- [Laravel Documentation](https://laravel.com/docs)
- [Docker Documentation](https://docs.docker.com/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Supervisor Documentation](http://supervisord.org/)

