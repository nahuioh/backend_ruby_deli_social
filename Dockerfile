# Usa la imagen oficial de Ruby como base
FROM ruby:3.2

# Instala dependencias del sistema
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

# Crea y establece el directorio de trabajo
WORKDIR /app

# Copia el Gemfile y Gemfile.lock y luego instala las gemas
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copia el resto del código de la aplicación
COPY . .

# Expone el puerto en el que la aplicación estará corriendo
EXPOSE 3000

# Define el comando para iniciar la aplicación
CMD ["rails", "server", "-b", "0.0.0.0"]
