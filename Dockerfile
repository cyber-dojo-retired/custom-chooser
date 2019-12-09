FROM cyberdojo/sinatra-base
LABEL maintainer=jon@jaggersoft.com

WORKDIR /app
COPY --chown=nobody:nogroup . .

ARG SHA
ENV SHA=${SHA}

ARG PORT
ENV PORT=${PORT}
EXPOSE ${PORT}

USER nobody
CMD [ "./up.sh" ]
