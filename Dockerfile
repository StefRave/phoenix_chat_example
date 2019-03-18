FROM elixir:1.7.2-alpine AS builder
EXPOSE 4000
CMD ["mix", "phx.server"]
RUN apk add --no-cache nodejs nodejs-npm
ENV HOST=localhost
ENV PORT=4000
ENV MIX_ENV=prod
RUN apk update \
 && apk add bash

WORKDIR /opt/app
COPY . .
RUN mix local.hex --force \
 && mix local.rebar --force \
 && mix deps.get \
 && mix deps.compile \
 && npm install \
 && mix release.init \
 && mix release


RUN mkdir -p /opt/built && \
  cp _build/prod/rel/chat/releases/0.0.1/chat.tar.gz /opt/built && \
  cd /opt/built && \
  tar -xzf chat.tar.gz && \
  rm chat.tar.gz

# This should match the version of Alpine that the `elixir:1.7.2-alpine` image uses
FROM alpine:3.8
RUN apk update && \
    apk add --no-cache bash openssl-dev

ENV HOST=localhost
ENV PORT=4000
ENV REPLACE_OS_VARS=true
WORKDIR /opt/app
COPY --from=builder /opt/built .
CMD trap 'exit' INT; /opt/app/bin/chat foreground