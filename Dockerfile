FROM ruby:2.4-alpine

MAINTAINER Néstor Coppi <nestorcoppi@gmail.com>

# Configuración de gems y dependencias
RUN echo "gem: --no-rdoc --no-ri" >> ~/.gemrc \
    && apk --update add --virtual build-dependencies build-base gcc postgresql-dev linux-headers libxml2 libxml2-dev libxml2-utils libxslt libxslt-dev \
    && apk --update add libpq bash nodejs zlib tzdata git imagemagick \
    && gem install bundler -v 1.17.3

WORKDIR /firehouse
ADD . .

# Instalar las gems con Bundler 1.17.3
RUN bundle _1.17.3_ install --deployment --jobs 8 \
    && apk del build-dependencies

# Crear tmp folder
RUN mkdir -p /firehouse/tmp

# Precompilar assets
RUN bundle exec rake assets:precompile
RUN bundle exec rake assets:clean

# Variables de entorno necesarias
ENV RAILS_ENV=production
ENV PORT=3000

# Ejecutar Puma directamente
CMD ["bundle", "exec", "puma", "-t", "5:5", "-p", "3000", "-e", "production"]
