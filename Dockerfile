# Usamos Ruby 2.5 con Debian Buster (más compatible con Rails 4.2.8)
FROM ruby:2.5-buster

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
  build-essential \
  libpq-dev \
  imagemagick \
  git \
  curl \
  bash \
  nodejs \
  npm \
  && rm -rf /var/lib/apt/lists/*

# Definir directorio de la app
WORKDIR /app

# Copiar gemfiles primero (para aprovechar cache)
COPY Gemfile Gemfile.lock ./

# Instalar Bundler compatible con Rails 4
RUN gem install bundler -v "~>1.17" && \
    bundle install --jobs 4 --retry 3

# Copiar el resto del código
COPY . .

# Variables necesarias
ENV RAILS_ENV=production
ENV RACK_ENV=production

# Precompilar assets (fallar silenciosamente si no hay assets)
RUN bundle exec rake assets:precompile RAILS_ENV=production || echo "Assets precompile skipped"

# Puerto
EXPOSE 3000

# Comando de arranque (usando unicorn, porque lo tenés en el Gemfile)
CMD ["bundle", "exec", "unicorn", "-c", "config/unicorn.rb", "-E", "production"]
