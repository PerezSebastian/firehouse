# 1️⃣ Imagen base Ruby 2.5.9 con Debian Buster
FROM ruby:2.5.9-buster

MAINTAINER Sebastian Perez <psebastian10101010@gmail.com>

# 2️⃣ Instalar dependencias del sistema necesarias
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev imagemagick git zlib1g-dev libxml2-dev libxslt1-dev curl nodejs npm yarn bash && \
    rm -rf /var/lib/apt/lists/*

# 3️⃣ Instalar bundler compatible con Rails 4.2
RUN gem install bundler -v 1.17.3

# 4️⃣ Crear directorio de la app y setear WORKDIR
RUN mkdir /firehouse
WORKDIR /firehouse

# 5️⃣ Copiar Gemfile y Gemfile.lock primero (para cache de Docker)
COPY Gemfile Gemfile.lock ./

# 6️⃣ Instalar gems
RUN bundle _1.17.3_ install --jobs 8 --deployment

# 7️⃣ Copiar el resto de la app
COPY . .

# 8️⃣ Variables de entorno necesarias para Rails
ARG SECRET_KEY_BASE
ENV RAILS_ENV=production
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE
ENV NODE_ENV=production
ENV LANG=C.UTF-8

# 9️⃣ Crear carpeta tmp requerida por Rails
RUN mkdir -p /firehouse/tmp

# 🔹 Precompilar assets de Rails
RUN bundle exec rake assets:precompile RAILS_ENV=production
RUN bundle exec rake assets:clean

# 10️⃣ Exponer puerto usado por Puma
EXPOSE 3000

# 11️⃣ Comando para iniciar Puma
CMD ["bundle", "exec", "puma", "-t", "5:5", "-p", "3000", "-e", "production"]
