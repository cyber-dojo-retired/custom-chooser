FROM cyberdojo/sinatra-base
LABEL maintainer=jon@jaggersoft.com

WORKDIR /app
COPY --chown=nobody:nogroup src .

ARG SHA
ENV SHA=${SHA}

ARG PORT
ENV PORT=${PORT}
EXPOSE ${PORT}

USER nobody
CMD [ "/app/up.sh" ]
