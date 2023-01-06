FROM nginx:1.21-alpine

RUN rm /etc/nginx/conf.d/default.conf
COPY ./services/blocks /etc/nginx/conf.d
