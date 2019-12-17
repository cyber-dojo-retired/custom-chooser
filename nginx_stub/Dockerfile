FROM  nginx:latest
LABEL maintainer=jon@jaggersoft.com

ARG NGINX_DIR=/usr/share/nginx/html
COPY images ${NGINX_DIR}/images
RUN chmod -R +r ${NGINX_DIR}

COPY nginx.conf /etc/nginx/conf.d/default.conf

ARG SHA
ENV SHA=${SHA}
RUN echo ${SHA} > ${NGINX_DIR}/sha.txt
