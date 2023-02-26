FROM ruby:3.1-alpine AS baseline
ARG ENVIRONMENT=development
ENV ENV=${ENVIRONMENT}

WORKDIR /usr/src/app

RUN apk update && apk upgrade && apk add bash gcompat nodejs openssh postgresql-dev
RUN gem update bundler
RUN bundle config set path 'vendor/bundle'

FROM baseline AS build-deps
RUN apk add alpine-sdk build-base
RUN bundle config set with ${ENVIRONMENT}
COPY Gemfile Gemfile.lock .

FROM baseline AS server

ARG PORT=3030
ENV PORT=${PORT}
EXPOSE ${PORT}/tcp
COPY . .
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

# Build stage that installs bundled gems (for local development)
FROM build-deps AS bundle-installer
CMD ["bundle", "install"]

# Build stage that runs pending migrations (for local development)
FROM server AS db-migrater

CMD ["bundle", "exec", "rails", "db:migrate"]

# Build stages to wrap the server with an installed bundle
# without including installation-only dependencies
# For production deployments.

FROM build-deps AS bundle
RUN bundle install

FROM server AS server-shrinkwrapped
COPY --from=bundle vendor/bundle ./vendor/bundle