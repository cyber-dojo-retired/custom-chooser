FROM cyberdojo/sinatra-base
LABEL maintainer=jon@jaggersoft.com

WORKDIR /app
COPY --chown=nobody:nogroup . .

ARG SHA
ENV SHA=${SHA}

EXPOSE 4536

USER nobody
CMD [ "./up.sh" ]
