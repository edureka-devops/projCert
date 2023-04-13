FROM php:7.4-apache

WORKDIR /var/www/html

COPY ./website /var/www/html

EXPOSE 80

CMD ["apache2-foreground"]

