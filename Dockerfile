FROM nifty/elixir

ENV HOST=localhost
ENV PORT=4000
ENV MIX_ENV=prod

# Compiles external dependencies first
ADD ./mix.* /app/

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar && \
    mix deps.get && \
    mix compile

# Now compile our application
ADD ./ /app
RUN mix compile

CMD mix phoenix.server
