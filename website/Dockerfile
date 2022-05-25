FROM ubuntu
RUN apt-get update -y
RUN apt-get install nginx -y
COPY index.php /var/www/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]