# Dockerfile para Firehouse (Rails 4.2 / Ruby 2.5) — usa repos archivados de Buster
FROM ruby:2.5-slim-buster

LABEL maintainer="Sebastian Perez <psebastian10101010@gmail.com>"

# 0) Preparar apt para Buster archivado y evitar errores 404/valid-until
RUN sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list \
 && sed -i 's|security.debian.org|archive.debian.org/debian-security|g' /etc/apt/sources.list \
 && printf 'Acquire::Check-Valid-Until "false";\n' > /etc/apt/apt.conf.d/99no-check-valid-until

# 1) Instalar dependencias del sistema mínimas (no metemos paquetes inútiles)
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      imagemagick \
      git \
      curl \
      ca-certificates \
      gnupg2 \
      dirmngr \
      bash \
    && rm -rf /var/lib/apt/lists/*

# 2) Instalar Node.js 14 (compatible con Rails 4 assets)
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get update -qq && apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# 3) Instalar Yarn (oficial)
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list && \
    apt-get update -qq && apt-get install -y --no-install-recommends yarn && \
    rm -rf /var/lib/apt/lists/*

# 4) Crear directorio de la app
WORKDIR /app

# 5) Copiar Gemfiles primero para usar cache de Docker
COPY Gemfile Gemfile.lock ./

# 6) Instalar Bundler versión compatible con tu Gemfile.lock (1.17.3 si tu lock lo pide)
#    Ajustá a la versión que figura en tu Gemfile.lock bajo "BUNDLED WITH"
RUN gem install bundler -v 1.17.3
RUN bundle _1.17.3_ install --without development test --jobs 4 --retry 3

# 7) Copiar el resto del código
COPY . .

# 8) Claro: usamos variables de entorno en Render; aquí sólo definimos RAILS_ENV
ENV RAILS_ENV=production

# 9) Precompilar assets (asegurate de tener SECRET_KEY_BASE en env de Render)
RUN bundle exec rake assets:precompile RAILS_ENV=production || ( echo "assets:precompile falló — ver logs" && exit 1 )

# 10) Puerto que unicorn/unicorn.rb va a usar (tu unicorn.rb debe usar ENV['PORT'] o 8080)
EXPOSE 8080

# 11) Command: arrancar Unicorn en producción
CMD ["bundle", "exec", "unicorn", "-c", "config/unicorn.rb", "-E", "production"]
