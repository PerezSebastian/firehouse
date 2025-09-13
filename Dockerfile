# Usamos Ruby 2.5.9
FROM ruby:2.5.9

MAINTAINER Sebastian Perez <psebastian10101010@gmail.com>

# Dependencias del sistema necesarias
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    npm \
    yarn \
    imagemagick \
    git \
    zlib1g-dev \
    libxml2-dev \
    libxslt1-dev \
    && rm -rf /var/lib/apt/lists/*

# Instalar Bundler 1.17.3
RUN gem install bundler -v 1.17.3

# Crear directorio de la app
RUN mkdir /firehouse
WORKDIR /firehouse

# Copiar Gemfile primero para aprovechar cache de Docker
COPY Gemfile Gemfile.lock ./

# Instalar gems con Bundler 1.17.3
RUN bundle _1.17.3_ install --jobs 8 --deployment

# Copiar el resto de la app
COPY . .

# Configurar variables de entorno necesarias para Rails
ARG SECRET_KEY_BASE
ENV RAILS_ENV=production
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE
ENV NODE_ENV=production

# Crear tmp folder requerido por Rails
RUN mkdir -p /firehouse/tmp

# Precompilar assets de Rails
RUN bundle exec rake assets:precompile RAILS_ENV=production
RUN bundle exec rake assets:clean

# Exponer puerto para Render
EXPOSE 3000

# Comando para arrancar Puma
CMD ["bundle", "exec", "puma", "-t", "5:5", "-p", "3000", "-e", "production"]
