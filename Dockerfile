# syntax=docker/dockerfile:1
# BuildKit cache mounts speed up CI/production rebuilds; enable with DOCKER_BUILDKIT=1 (default in Buildx).
FROM timbru31/ruby-node:3.5-slim-24 AS baseline

WORKDIR /usr/src/app

# delete old nodesource, which doesn't get updated upon key refresh and still tries to use SHA1
RUN rm -f /etc/apt/sources.list.d/nodesource.list
# fetch new gpg key for downloading nodejs
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /usr/share/keyrings/nodesource.gpg
RUN apt update -y && apt upgrade -y && apt install postgresql -y
RUN gem update bundler
RUN bundle config set path 'vendor/bundle'

# Stage that configures necessary components for installing/building dependencies
FROM baseline AS server
ARG ENVIRONMENT=development
ENV RAILS_ENV=${ENVIRONMENT}
RUN apt install -y \
    build-essential \
    imagemagick \
    libffi-dev \
    # needed for certain rust native extensions
    libclang-dev \
    # used to simplify local debugging - not big enough to be a problem for production deployments
    vim
RUN bundle config set with ${ENVIRONMENT}
RUN bundle config build.ffi --enable-system-libffi
COPY Gemfile Gemfile.lock ./
RUN --mount=type=cache,id=bundler-${TARGETARCH},target=/usr/src/app/vendor/cache \
    bundle config set --local cache_path vendor/cache && \
    bundle install
COPY package.json package-lock.json ./
RUN --mount=type=cache,id=npm-${TARGETARCH},target=/root/.npm \
    npm ci
ARG PORT
ENV PORT=${PORT}
COPY . .
CMD bundle exec rails server -b :: -p $PORT

# ==== DEPLOYABLE CONTAINER STAGES ====

# Build stages to wrap the server with an installed bundle
# and any necessary production-only resources
# without including installation-only dependencies.
# For production deployments.

FROM server AS server-shrinkwrapped
RUN --mount=type=secret,id=CREDENTIALS_KEY,env=RAILS_MASTER_KEY bundle exec rails assets:precompile

# ==== LOCAL DEVELOPMENT CONTAINER STAGES ====

# Sidecar container that installs bundled gems
FROM server AS bundle-installer
CMD ["bundle", "install"]

# Sidecar container that installs npm packages (local dev; compose mounts node_modules volume)
FROM server AS npm-installer
CMD ["npm", "install"]

# Sidecar container that runs pending migrations
FROM server AS db-migrater

CMD ["bundle", "exec", "rails", "db:migrate"]
