FROM devopsedu/webapp
RUN apt-get update
RUN apt-get install apache2 -y
RUN apt-get install php libapache2-mod-php php-cli -y
RUN rm -rf /var/www/html/*
ADD website /var/www/html/
EXPOSE 80
CMD ["/usr/sbin/apache2ctl","-D", "FOREGROUND"]
