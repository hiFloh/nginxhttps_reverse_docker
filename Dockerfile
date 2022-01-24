FROM nginx

COPY ./start /start
COPY ./setup.sh /docker-entrypoint.d/09-setup.sh
