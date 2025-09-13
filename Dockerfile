# Usamos Ruby 2.5.9-slim (más estable para Rails antiguo)
FROM ruby:2.5.9-slim

MAINTAINER Sebastian Perez <psebastian10101010@gmail.com>

# 1️⃣ Instalar dependencias del sistema
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
    bash \
    && rm -rf /var/lib/apt/lists/*

# 2️⃣ Instalar Bundler compatible con Rails antiguo
RUN gem install bundler -v 1.17.3

# 3️⃣ Crear directorio de la app y establecer WORKDIR
RUN mkdir /firehouse
WORKDIR /firehouse

# 4️⃣ Copiar Gemfile primero para aprovechar cache de Docker
COPY Gemfile Gemfile.lock ./

# 5️⃣ Instalar gems
RUN bundle _1.17.3_ install --jobs 8 --deployment

# 6️⃣ Copiar el resto de la app
COPY . .

# 7️⃣ Configurar variables de entorno necesarias
ARG SECRET_KEY_BASE
ENV RAILS_ENV=production
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE
ENV NODE_ENV=production
ENV LANG=C.UTF-8

# 8️⃣ Crear carpeta tmp requerida por Rails
RUN mkdir -p /firehouse/tmp

# 9️⃣ Precompilar assets de Rails
# Nota: si falla, podemos hacerlo manualmente desde Shell en Render
RUN bundle exec rake assets:precompile RAILS_ENV=production
RUN bundle exec rake assets:clean

# 10️⃣ Exponer puerto que usa Puma
EXPOSE 3000

# 11️⃣ Comando para iniciar Puma
CMD ["bundle", "exec", "puma", "-t", "5:5", "-p", "3000", "-e", "production"]
