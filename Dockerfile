FROM ruby:2.5-buster

# Fix Debian buster repos (now archived)
RUN sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list \
 && sed -i '/security.debian.org/d' /etc/apt/sources.list \
 && apt-get update -qq \
 && apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      imagemagick \
      git \
      curl \
      bash \
      nodejs \
      npm \
 && npm install -g yarn \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY Gemfile Gemfile.lock ./

RUN gem install bundler -v 2.4.22 \
 && bundle install --without development test

COPY . .

# Precompilar assets para producción
RUN bundle exec rake assets:precompile RAILS_ENV=production

EXPOSE 8080
CMD ["bundle", "exec", "unicorn", "-c", "config/unicorn.rb"]
