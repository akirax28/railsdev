FROM ruby:2.7.1-alpine3.11
RUN apk add --update --no-cache \
      binutils-gold \
      build-base \
      curl \
      file \
      g++ \
      gcc \
      git \
      less \
      libstdc++ \
      libffi-dev \
      libc-dev \
      linux-headers \
      libxml2-dev \
      libxslt-dev \
      libgcrypt-dev \
      make \
      netcat-openbsd \
      nodejs \
      openssl \
      pkgconfig \
      postgresql-dev \
      python \
      tzdata \
      yarn

RUN gem install rails
# Set an environment variable to store where the app is installed inside
# of the Docker image.
ENV INSTALL_PATH /app
RUN mkdir -p $INSTALL_PATH

# This sets the context of where commands will be ran in and is documented
# on Docker's website extensively.
WORKDIR $INSTALL_PATH

# Use the Gemfiles as Docker cache markers. Always bundle before copying app src.
# (the src likely changed and we don't want to invalidate Docker's cache too early)
# http://ilikestuffblog.com/2014/01/06/how-to-skip-bundle-install-when-deploying-a-rails-app-to-docker/

COPY Gemfile Gemfile.lock ./
COPY . ./
# Set RAILS_ENV and RACK_ENV

ARG RAILS_ENV
ENV RACK_ENV=$RAILS_ENV
# Prevent bundler warnings; ensure that the bundler version executed is >= that which created Gemfile.lock
RUN gem install bundler \
	&& bundle config build.nokogiri --use-system-libraries \
	&& RUN bundle check || bundle install \
	&& yarn install --check-files
COPY package.json yarn.lock ./
# Finish establishing our Ruby enviornment depending on the RAILS_ENV
RUN if [[ "$RAILS_ENV" == "production" ]]; then bundle install --without development test; else bundle install; fi

# Copy the main application.

ENTRYPOINT ["./entrypoints/docker-entrypoint.sh"]
#CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
