FROM ruby:3.1-alpine AS baseline

WORKDIR /usr/src/app

RUN apk update && apk upgrade && apk add bash gcompat nodejs openssh postgresql-dev
RUN gem update bundler
RUN bundle config set path 'vendor/bundle'

# Stage that configures necessary components for installing/building dependencies
FROM baseline AS server
ARG ENVIRONMENT=development
RUN apk add alpine-sdk build-base
RUN bundle config set with ${ENVIRONMENT}

ARG PORT
ENV PORT=${PORT}
COPY . .
CMD bundle exec rails server -b 0.0.0.0 -p ${PORT}

# ==== DEPLOYABLE CONTAINER STAGES ====

# Build stages to wrap the server with an installed bundle
# without including installation-only dependencies
# For production deployments.

FROM server AS server-shrinkwrapped
RUN bundle install

# ==== LOCAL DEVELOPMENT CONTAINER STAGES ====

# Sidecar container that installs bundled gems
FROM server AS bundle-installer
CMD ["bundle", "install"]

# Sidecar container that runs pending migrations
FROM server AS db-migrater

CMD ["bundle", "exec", "rails", "db:migrate"]