FROM ruby:3.2-bullseye AS baseline

WORKDIR /usr/src/app

RUN apt update -y && apt upgrade -y && apt install nodejs postgresql -y
RUN gem update bundler
RUN bundle config set path 'vendor/bundle'

# Stage that configures necessary components for installing/building dependencies
FROM baseline AS server
ARG ENVIRONMENT=development
ENV RAILS_ENV=${ENVIRONMENT}
# vim included to simplify local debugging - not big enough to be a problem
# for production deployments
RUN apt install build-essential imagemagick libffi-dev vim -y
RUN bundle config set with ${ENVIRONMENT}
RUN bundle config build.ffi --enable-system-libffi
COPY Gemfile Gemfile.lock ./
RUN bundle install
ARG PORT
ENV PORT=${PORT}
COPY . .
CMD bundle exec rails server -b 0.0.0.0 -p ${PORT}

# ==== DEPLOYABLE CONTAINER STAGES ====

# Build stages to wrap the server with an installed bundle
# and any necessary production-only resources
# without including installation-only dependencies.
# For production deployments.

FROM server AS server-shrinkwrapped
# Tel this step not to require SECRET_KEY_BASE
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

# ==== LOCAL DEVELOPMENT CONTAINER STAGES ====

# Sidecar container that installs bundled gems
FROM server AS bundle-installer
CMD ["bundle", "install"]

# Sidecar container that runs pending migrations
FROM server AS db-migrater

CMD bundle exec rails db:migrate
