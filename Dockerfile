FROM ruby:2.7.1-alpine3.11
RUN apk add --no-cache --update build-base \
                                linux-headers \
                                postgresql-dev \
				postgresql-client\
                                tzdata \
                                git \
                                nodejs \
                                yarn \
                                libc6-compat\
				libxslt-dev\
				libxml2-dev\
				imagemagick
RUN gem install rails
# Set an environment variable to store where the app is installed inside
# of the Docker image.
ENV INSTALL_PATH /app_name
RUN mkdir -p $INSTALL_PATH

# This sets the context of where commands will be ran in and is documented
# on Docker's website extensively.
WORKDIR $INSTALL_PATH

# Set NEW and NEW_RAILS

ENV NEW_RAILS=$NEW
ENV DB_SET

# Use the Gemfiles as Docker cache markers. Always bundle before copying app src.
# (the src likely changed and we don't want to invalidate Docker's cache too early)
# http://ilikestuffblog.com/2014/01/06/how-to-skip-bundle-install-when-deploying-a-rails-app-to-docker/

COPY Gemfile Gemfile.lock ./

# Rails new app 


# Set RAILS_ENV and RACK_ENV

ARG RAILS_ENV
ENV RACK_ENV=$RAILS_ENV

# Prevent bundler warnings; ensure that the bundler version executed is >= that which created Gemfile.lock
RUN gem install bundler

# Finish establishing our Ruby enviornment depending on the RAILS_ENV
RUN if [[ "$RAILS_ENV" == "production" ]]; then bundle install --without development test; else bundle install; fi

# Copy the main application.

COPY . ./

CMD ["bundle", "exec", "rails", "s"]
