FROM nginx:1.25-alpine

# Instalar herramientas adicionales
RUN apk add --no-cache \
    curl \
    openssl

# Copiar configuración personalizada
COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d/ /etc/nginx/conf.d/

# Crear directorios necesarios
RUN mkdir -p /var/cache/nginx/client_temp \
    && mkdir -p /var/cache/nginx/proxy_temp \
    && mkdir -p /var/cache/nginx/fastcgi_temp \
    && mkdir -p /etc/nginx/ssl

# Crear certificado SSL auto-firmado para desarrollo
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx-selfsigned.key \
    -out /etc/nginx/ssl/nginx-selfsigned.crt \
    -subj "/C=MX/ST=State/L=City/O=Organization/OU=OrgUnit/CN=localhost"

# Configurar permisos
RUN chown -R nginx:nginx /var/cache/nginx \
    && chown -R nginx:nginx /etc/nginx/ssl

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
