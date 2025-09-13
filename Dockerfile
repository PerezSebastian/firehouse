# Usamos Ruby 2.5 con Debian Slim actual
FROM ruby:2.5.9-slim

# Instalar dependencias del sistema
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev imagemagick git curl bash nodejs npm yarn && \
    rm -rf /var/lib/apt/lists/*

# Crear directorio de la app
WORKDIR /app

# Copiar Gemfile y Gemfile.lock primero para cachear bundle install
COPY Gemfile Gemfile.lock ./

# Instalar Bundler compatible con Ruby 2.5
RUN gem install bundler -v 2.1.4
RUN bundle _2.1.4_ install --without development test

# Copiar el resto del código
COPY . .

# Precompilar assets para producción usando variables de entorno
ENV RAILS_ENV=production
RUN bundle exec rake assets:precompile

# Exponer puerto 8080
EXPOSE 8080

# Comando para iniciar Unicorn
CMD ["bundle", "exec", "unicorn", "-c", "config/unicorn.rb"]
