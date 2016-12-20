FROM elixir:1.2-slim
MAINTAINER Cedric Charly <cedric.charly@gmail.com>

ARG MIX_ENV

ENV MIX_ENV=${MIX_ENV:-prod} \
    LANG=C.UTF-8

RUN mkdir -p /app
WORKDIR /app

COPY . /app

RUN apt-get update && \
    apt-get install -y libssl1.0.0 postgresql-client --no-install-recommends && \
    apt-get autoclean

RUN mix local.hex --force \
    && mix local.rebar --force \
    && mix deps.get \
    && mix deps.compile \
    && mix compile \
    && mix phoenix.digest

CMD ["elixir", "-S", "mix", "phoenix.server", "--no-deps-check", "--no-compile", "--no-halt"]
