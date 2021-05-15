FROM nginx

COPY ./sites/ /etc/nginx/conf.d/
#COPY ./conf/ /etc/nginx/conf.d/

