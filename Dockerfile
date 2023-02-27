FROM ruby:3.1-alpine AS baseline

WORKDIR /usr/src/app

RUN apk update && apk upgrade && apk add bash gcompat nodejs openssh postgresql-dev
RUN gem update bundler
RUN bundle config set path 'vendor/bundle'

# Stage that configures necessary components for installing/building dependencies
FROM baseline AS build-deps
ARG ENVIRONMENT=development
RUN apk add alpine-sdk build-base
RUN bundle config set with ${ENVIRONMENT}
COPY Gemfile Gemfile.lock ./

FROM baseline AS server
ARG PORT
COPY . .
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0" "-p", "$PORT"]

# ==== DEPLOYABLE CONTAINER STAGES ====

# Build stages to wrap the server with an installed bundle
# without including installation-only dependencies
# For production deployments.

FROM build-deps AS bundle
RUN bundle install

FROM server AS server-shrinkwrapped
COPY --from=bundle /usr/src/app/vendor/bundle ./vendor/bundle

# ==== LOCAL DEVELOPMENT CONTAINER STAGES ====

# Sidecar container that installs bundled gems
FROM build-deps AS bundle-installer
CMD ["bundle", "install"]

# Sidecar container that runs pending migrations
FROM server AS db-migrater

CMD ["bundle", "exec", "rails", "db:migrate"]