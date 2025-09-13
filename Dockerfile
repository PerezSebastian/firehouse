# 1️⃣ Imagen base: Ruby 2.5.9 con Debian Buster
FROM ruby:2.5.9-buster

MAINTAINER Sebastian Perez <psebastian10101010@gmail.com>

# 2️⃣ Instalar dependencias del sistema
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev imagemagick git zlib1g-dev libxml2-dev libxslt1-dev curl bash && \
    # NodeJS 16
    curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs && \
    # Yarn
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn && \
    rm -rf /var/lib/apt/lists/*

# 3️⃣ Instalar Bundler compatible con Rails antiguo
RUN gem install bundler -v 1.17.3

# 4️⃣ Crear directorio de la app y establecer WORKDIR
RUN mkdir /firehouse
WORKDIR /firehouse

# 5️⃣ Copiar Gemfile primero (para cache de Docker)
COPY Gemfile Gemfile.lock ./

# 6️⃣ Instalar gems
RUN bundle _1.17.3_ install --jobs 8 --deployment

# 7️⃣ Copiar el resto de la app
COPY . .

# 8️⃣ Configurar variables de entorno necesarias
ARG SECRET_KEY_BASE
ENV RAILS_ENV=production
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE
ENV NODE_ENV=production
ENV LANG=C.UTF-8

# 9️⃣ Crear carpeta tmp requerida por Rails
RUN mkdir -p /firehouse/tmp

# 10️⃣ Precompilar assets de Rails
RUN bundle exec rake assets:precompile RAILS_ENV=production
RUN bundle exec rake assets:clean

# 11️⃣ Exponer puerto que usa Puma
EXPOSE 3000

# 12️⃣ Comando para iniciar Puma
CMD ["bundle", "exec", "puma", "-t", "5:5", "-p", "3000", "-e", "production"]
