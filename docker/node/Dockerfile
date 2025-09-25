FROM node:22-alpine

# Instalar dependencias del sistema
RUN apk add --no-cache \
    git \
    openssh-client \
    python3 \
    make \
    g++

# Configurar directorio de trabajo
WORKDIR /var/www/html

# Crear usuario node (usar ID disponible si 1000 está ocupado)
RUN adduser -u 1000 -s /bin/sh -D node_user 2>/dev/null || \
    adduser -u 1001 -s /bin/sh -D node_user

# Configurar npm para mejor rendimiento
RUN npm config set fund false && \
    npm config set audit-level moderate && \
    npm install -g npm@latest

# Cambiar propietario del directorio
RUN chown -R node_user:$(id -gn node_user) /var/www/html

# Cambiar al usuario node_user
USER node_user

# Exponer puertos para Vite
EXPOSE 5173 3000

# Comando por defecto
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
