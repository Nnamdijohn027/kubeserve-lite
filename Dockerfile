FROM nginx:alpine
RUN apk add --no-cache php82 php82-fpm
COPY app/index.html /usr/share/nginx/html/index.html
COPY app/hostname.php /usr/share/nginx/html/hostname.php
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
