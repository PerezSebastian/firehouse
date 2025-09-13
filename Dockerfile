# Imagen base Ruby 2.5.9
FROM ruby:2.5.9-buster

MAINTAINER Sebastian Perez <psebastian10101010@gmail.com>

# 1️⃣ Instalar dependencias del sistema básicas
RUN apt-get update && \
    apt-get install -y build-essential libpq-dev imagemagick git curl bash && \
    rm -rf /var/lib/apt/lists/*

# 2️⃣ Instalar Node.js 14 LTS (compatible con Rails 4.2)
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# 3️⃣ Instalar Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y yarn && \
    rm -rf /var/lib/apt/lists/*

# 4️⃣ Crear directorio de la app
RUN mkdir /firehouse
WORKDIR /firehouse

# 5️⃣ Copiar Gemfile y Gemfile.lock
COPY Gemfile Gemfile.lock ./

# 6️⃣ Instalar bundler y gems
RUN gem install bundler -v 1.17.3
RUN bundle _1.17.3_ install --jobs 8 --deployment

# 7️⃣ Copiar el resto de la app
COPY . .

# 8️⃣ Variables de entorno
ENV RAILS_ENV=production
ENV NODE_ENV=production
ARG SECRET_KEY_BASE
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE
ENV LANG=C.UTF-8

# 9️⃣ Crear carpeta tmp requerida por Rails
RUN mkdir -p tmp

# 🔹 Precompilar assets
RUN bundle exec rake assets:precompile RAILS_ENV=production
RUN bundle exec rake assets:clean

# 10️⃣ Exponer puerto
EXPOSE 3000

# 11️⃣ Comando para iniciar Puma
CMD ["bundle", "exec", "puma", "-t", "5:5", "-p", "3000", "-e", "production"]
