FROM elixir:1.2-slim
MAINTAINER Cedric Charly <cedric.charly@gmail.com>

ENV MIX_ENV=prod \
    LANG=C.UTF-8

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY . /usr/src/app

RUN mix local.hex --force \
    && mix local.rebar --force \
    && mix deps.get \
    && mix deps.compile \
    && mix compile \
    && mix phoenix.digest

CMD ["elixir", "-S", "mix", "phoenix.server", "--no-deps-check", "--no-compile", "--no-halt"]
