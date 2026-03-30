FROM elixir:1.16-alpine

RUN apk add --no-cache \
    build-base \
    git \
    nodejs \
    npm \
    postgresql-client \
    inotify-tools

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install hex phx_new --force

WORKDIR /app

EXPOSE 4000

CMD ["/bin/sh"]
