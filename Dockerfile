# Laravel5 Docker

# Pull base image.
FROM registry.kube.pars/library/php-generic:7

MAINTAINER Reza Ghanbari "rezapython@gmail.com"

# Copy entrypoint
COPY entrypoint.sh /

# composer install
COPY ["composer.json", "composer.lock", "/var/www/"]
RUN  apt-get update && apt-get install -y php7.0-mysql nginx && cd /var/www &&  \
        composer install --no-autoloader --no-scripts

# Copy project files
COPY . /var/www

# Run composer commands
RUN cd /var/www && composer install && \
        chown -R www-data. /var/www && chmod +x /entrypoint.sh

# Define working directory.
WORKDIR /var/www

ENTRYPOINT ["/entrypoint.sh"]

