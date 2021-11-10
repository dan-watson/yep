FROM ruby:3.0.2-slim
MAINTAINER dan@paz.am
ENV REFRESHED_AT 2021-11-09

# Install packages
RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential \
      git \
      && rm -rf /var/lib/apt/lists/*

# Setup app location
RUN mkdir -p /app
WORKDIR /app

# Install gems
ADD yep.gemspec /app/yep.gemspec
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
ADD lib/ /app/lib
ADD test/ /app/test

RUN bundle install --jobs 4
