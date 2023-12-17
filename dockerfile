FROM devopsedu/webapp
ADD projCert/website /var/www/html
RUN rm /var/www/html/index.html
CMD apachectl -D FOREGROUND
