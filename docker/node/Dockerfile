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

# Usar el usuario node existente (UID ya es 1000 en la imagen base de Node Alpine)
# Cambiar propietario del directorio para el usuario node
RUN chown -R node:node /var/www/html

# Configurar npm para mejor rendimiento
RUN npm config set fund false && \
    npm config set audit-level moderate && \
    npm install -g npm@latest

# Cambiar al usuario node
USER node

# Exponer puertos para Vite
EXPOSE 5173 3000

# Comando por defecto
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
