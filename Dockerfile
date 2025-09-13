# Imagen base Ruby 2.5.9 con Node.js 12 (ya incluye Yarn)
FROM ruby:2.5.9-node12-buster

MAINTAINER Sebastian Perez <psebastian10101010@gmail.com>

# Instalar dependencias del sistema necesarias (solo lo mínimo)
RUN apt-get update -qq && \
    apt-get install -y libpq-dev imagemagick git && \
    rm -rf /var/lib/apt/lists/*

# Crear directorio de la app
RUN mkdir /firehouse
WORKDIR /firehouse

# Copiar Gemfile primero para aprovechar cache de Docker
COPY Gemfile Gemfile.lock ./

# Instalar bundler compatible con Rails 4.2
RUN gem install bundler -v 1.17.3
RUN bundle _1.17.3_ install --jobs 8 --deployment

# Copiar el resto de la app
COPY . .

# Variables de entorno
ENV RAILS_ENV=production
ENV NODE_ENV=production
ARG SECRET_KEY_BASE
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE
ENV LANG=C.UTF-8

# Crear carpeta tmp requerida por Rails
RUN mkdir -p tmp

# Precompilar assets
RUN bundle exec rake assets:precompile RAILS_ENV=production
RUN bundle exec rake assets:clean

# Exponer puerto de Puma
EXPOSE 3000

# Comando para iniciar Puma
CMD ["bundle", "exec", "puma", "-t", "5:5", "-p", "3000", "-e", "production"]
