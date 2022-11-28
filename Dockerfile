FROM devopsedu/webapp

#Copy Application Files
RUN rm -rf /var/www/html/*
COPY website /var/www/html/
