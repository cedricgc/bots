FROM elixir:1.2-slim
MAINTAINER Cedric Charly <cedric.charly@gmail.com>

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY . /usr/src/app

RUN mix local.hex --force \
    && mix local.rebar --force \
    && mix deps.get \
    && mix deps.compile \
    && mix compile

CMD ["iex", "-S", "mix"]
