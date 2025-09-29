# SBoil - Plantilla Laravel Simplificada

Una plantilla **ultra-simplificada** de Docker para desarrollar y desplegar aplicaciones Laravel con **una sola imagen y un solo contenedor**.

## 🚀 Características

- **Una sola imagen** con PHP 8.4 + Nginx + Node.js 22
- **Un solo contenedor** que ejecuta todos los servicios
- **Supervisor** para manejar múltiples procesos
- **Redis** para cache, sesiones y colas
- **Vite** integrado para desarrollo frontend
- **Queue Workers** y **Scheduler** automáticos
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
# Ver todos los comandos disponibles
make help

# Iniciar la aplicación
make up

# Ver logs en tiempo real
make logs

# Acceder al contenedor
make shell

# Estado de contenedores
make status

# Reiniciar aplicación
make restart

# Detener aplicación
make down
```

### **Comandos de Laravel:**

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

### **Comandos de Node.js/Vite:**

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

### **Comandos de instalación:**

```bash
# Instalación completa desde cero
make fresh

# Solo instalar Laravel
make install-laravel

# Configurar .env
make setup-env
```

### **Comandos de producción:**

```bash
# Desplegar en producción
make deploy-prod

# Crear backup
make backup

# Optimizar para producción
make optimize
```

### **Comandos de limpieza:**

```bash
# Limpiar recursos Docker
make clean

# Limpiar todo (incluyendo imágenes)
make clean-all

# Eliminar completamente el proyecto
make destroy
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
   - **Forward Hostname/IP**: `sboil_app` (o IP del contenedor)
   - **Forward Port**: `80`
   - **Websockets Support**: ✅ Activado

2. **Desplegar:**
```bash
make deploy-prod
```

### **Sin Nginx Proxy Manager**

La aplicación expone automáticamente:
- **Puerto 80**: Aplicación Laravel
- **Puerto 5173**: Vite (desarrollo)

```bash
# Acceso directo
http://localhost        # Laravel
http://localhost:5173   # Vite (desarrollo)
```

## 🛠️ Desarrollo

### **Flujo de trabajo:**

```bash
# 1. Iniciar desarrollo
make dev

# 2. Acceder al contenedor
make shell

# 3. Ver logs
make logs

# 4. Ejecutar comandos Laravel
make artisan cmd="migrate"
make artisan cmd="make:controller UserController"

# 5. Instalar dependencias Node
make npm-install

# 6. Desarrollo frontend
make npm-dev
```

### **Servicios incluidos:**

- **Nginx**: Servidor web (puerto 80)
- **PHP-FPM**: Procesador PHP
- **Node.js**: Vite dev server (puerto 5173)
- **Queue Worker**: Procesamiento de colas
- **Scheduler**: Tareas programadas (cron)
- **Redis**: Cache y sesiones

## 📊 Ventajas de la Simplificación

### **✅ Ventajas:**

- **Ultra-simple**: Un solo contenedor, una sola imagen
- **Fácil de replicar**: Copia y ejecuta
- **Menos recursos**: Un solo contenedor en lugar de 7
- **Configuración única**: Todo en un lugar
- **Despliegue rápido**: `make up` y listo
- **Debugging fácil**: Un solo lugar para logs
- **Mantenimiento simple**: Menos complejidad

### **🔄 Comparación:**

| Aspecto | Antes (7 contenedores) | Ahora (1 contenedor) |
|---------|----------------------|---------------------|
| **Complejidad** | Alta | Mínima |
| **Recursos** | 7 contenedores | 1 contenedor |
| **Configuración** | 7 servicios | 1 servicio |
| **Debugging** | 7 logs separados | 1 log unificado |
| **Despliegue** | Múltiples pasos | Un solo comando |

## 🎯 Casos de Uso

### **✅ Perfecto para:**

- **Desarrollo rápido** de aplicaciones Laravel
- **Prototipos** y MVPs
- **Aplicaciones pequeñas/medianas**
- **Desarrollo local** sin complejidad
- **Aprendizaje** de Laravel + Docker
- **Despliegues simples**

### **⚠️ Consideraciones:**

- **Escalabilidad**: Para aplicaciones muy grandes, considera microservicios
- **Recursos**: Un solo contenedor consume más memoria que contenedores separados
- **Aislamiento**: Menos aislamiento entre servicios

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

## 📚 Documentación Adicional

- [Laravel Documentation](https://laravel.com/docs)
- [Docker Documentation](https://docs.docker.com/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Supervisor Documentation](http://supervisord.org/)

## 🎉 Conclusión

**¡SBoil simplificado está listo!**

- ✅ **Ultra-simple**: Un solo contenedor
- ✅ **Fácil de usar**: Comandos intuitivos
- ✅ **Completamente funcional**: Laravel + Vite + Redis
- ✅ **Listo para producción**: Con Nginx Proxy Manager
- ✅ **Fácil de replicar**: Copia y ejecuta

**¡Happy coding! 🎉**
