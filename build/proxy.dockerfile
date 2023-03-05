FROM nginx

RUN rm /etc/nginx/conf.d/default.conf
COPY ./services/blocks /etc/nginx/conf.d
