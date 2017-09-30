FROM elixir:1.3

ENV HOST=localhost
ENV PORT=4000
ENV MIX_ENV=prod
ENV SSL_KEY_PATH=/certs/terminalanywhere.key
ENV SSL_CERT_PATH=/certs/terminalanywhere.crt

# Compiles external dependencies first
ADD ./mix.* /app/
ADD ./config/terminalanywhere.* /certs/

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar && \
    mix deps.get && \
    mix compile

# Now compile our application
ADD ./ /app
RUN mix compile

CMD mix phoenix.server
