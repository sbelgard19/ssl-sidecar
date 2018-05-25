FROM nginx

RUN apt update && apt install openssl

# Copy in conf files
COPY mime.types /etc/nginx/mime.types
COPY ssl.conf /etc/nginx/

WORKDIR /
COPY nginx.conf.template .
COPY setup.sh .

# Expose both the HTTP (80) and HTTPS (443) ports
EXPOSE 80 443

CMD ["bash", "-c", "./setup.sh; nginx"]