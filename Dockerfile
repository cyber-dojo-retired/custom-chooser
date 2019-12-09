FROM cyberdojo/sinatra-base
LABEL maintainer=jon@jaggersoft.com

COPY --chown=nobody:nogroup . /
WORKDIR /app

ARG SHA
ENV SHA=${SHA}

ARG PORT
ENV PORT=${PORT}
EXPOSE ${PORT}

USER nobody
CMD [ "/app/up.sh" ]
