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

# Crear usuario node
RUN addgroup -g 1000 node_group && adduser -u 1000 -G node_group -s /bin/sh -D node_user

# Configurar npm para mejor rendimiento
RUN npm config set fund false && \
    npm config set audit-level moderate && \
    npm install -g npm@latest

# Cambiar propietario del directorio
RUN chown -R node_user:node_group /var/www/html

# Cambiar al usuario node_user
USER node_user

# Exponer puertos para Vite
EXPOSE 5173 3000

# Comando por defecto
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
