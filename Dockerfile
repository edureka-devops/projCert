# Use an official PHP runtime as a parent image
FROM php:7.4-apache

# Set the working directory to /var/www/html
WORKDIR /var/www/html

# Copy the PHP application files from your Git repository into the container at /var/www/html
COPY . /var/www/html

# Install any necessary dependencies. For example, if your PHP application uses MySQL:
# RUN docker-php-ext-install pdo pdo_mysql

# Expose port 80 to allow incoming HTTP traffic
EXPOSE 80

# Define an environment variable to customize PHP settings (optional)
# ENV PHP_INI_SCAN_DIR /usr/local/etc/php/conf.d/

# Start the Apache web server when the container starts
CMD ["apache2-foreground"]
