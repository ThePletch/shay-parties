# syntax=docker/dockerfile:1
# BuildKit cache mounts speed up CI/production rebuilds; enable with DOCKER_BUILDKIT=1 (default in Buildx).
ARG RUBY_NODE_IMAGE=timbru31/ruby-node:3.5-slim-24@sha256:f02a381f5875c0730867a5fe85c16b5ece414ad0a5215bd2838eb34a3f21ccae

FROM ${RUBY_NODE_IMAGE} AS baseline

WORKDIR /usr/src/app

# delete old nodesource, which doesn't get updated upon key refresh and still tries to use SHA1
RUN rm -f /etc/apt/sources.list.d/nodesource.list \
  && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    | gpg --dearmor -o /usr/share/keyrings/nodesource.gpg \
  && apt-get update \
  && apt-get install -y --no-install-recommends libpq-dev \
  && rm -rf /var/lib/apt/lists/* \
  && gem install bundler -v 4.0.3 --no-document \
  && bundle config set path 'vendor/bundle'

# Stage that configures necessary components for installing/building dependencies
FROM baseline AS server
ARG ENVIRONMENT=development
ENV RAILS_ENV=${ENVIRONMENT}
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    build-essential \
    imagemagick \
    libffi-dev \
    # needed for certain rust native extensions
    libclang-dev \
    vim \
  && rm -rf /var/lib/apt/lists/*
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

# Compile production assets and drop install-only artifacts before the runtime image.
FROM server AS server-shrinkwrapped
RUN --mount=type=secret,id=CREDENTIALS_KEY,env=RAILS_MASTER_KEY \
    bundle exec rails assets:precompile \
  && rm -rf node_modules \
  && bundle clean --force

# Production ECS image: runtime libraries and application artifacts only.
FROM ${RUBY_NODE_IMAGE} AS runtime
WORKDIR /usr/src/app
RUN rm -f /etc/apt/sources.list.d/nodesource.list \
  && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    | gpg --dearmor -o /usr/share/keyrings/nodesource.gpg \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    libpq5 \
    imagemagick \
    libffi8 \
    vim \
  && apt-get purge -y --auto-remove nodejs libffi-dev \
  && rm -rf /var/lib/apt/lists/* \
  && gem install bundler -v 4.0.3 --no-document
ARG ENVIRONMENT=production
ENV RAILS_ENV=${ENVIRONMENT}
ENV BUNDLE_PATH=/usr/src/app/vendor/bundle
ARG PORT=3030
ENV PORT=${PORT}
COPY --from=server-shrinkwrapped /usr/src/app /usr/src/app
CMD bundle exec rails server -b :: -p $PORT

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
