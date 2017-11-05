#!/bin/bash
INDENT=5
INDENT=$(($INDENT-1))
APPNAME_FPM="
_IS_DEV=appname
_APP_NAME=appname
_APP_ENV=local

_APP_KEY=base64:R4IVDazNA3o7KOfmwD5UEd0Y3+Gg/7EJMfbmy4ZAGTY=
_APP_DEBUG=true
_APP_LOG_LEVEL=debug
_APP_URL=http://localhost
_DB_CONNECTION=mysql
_DB_HOST=db
_DB_PORT=3306
_DB_DATABASE=root
_DB_USERNAME=root
_DB_PASSWORD=root


_BROADCAST_DRIVER=log
_CACHE_DRIVER=file
_SESSION_DRIVER=file
_SESSION_LIFETIME=120
_QUEUE_DRIVER=sync

_REDIS_HOST=127.0.0.1
_REDIS_PASSWORD=null
_REDIS_DB=0
_REDIS_PORT=6379

_MAIL_DRIVER=smtp
_MAIL_HOST=smtp.mailtrap.io
_MAIL_PORT=2525
_MAIL_USERNAME=null
_MAIL_PASSWORD=null
_MAIL_ENCRYPTION=null

_PUSHER_APP_ID=
_PUSHER_APP_KEY=
_PUSHER_APP_SECRET=
"
env_generator() {
        for line in $@; do
                echo "`printf '%*s' "$INDENT"`- `echo $line | cut -d"=" -f1`=`echo $line | cut -d"=" -f2`"
        done
}

cat > docker-compose.yaml << EOL
version: '2'
services:

  db:
    restart: always
    image: percona
    environment:
    - MYSQL_USER=root
    - MYSQL_PASSWORD=root
    - MYSQL_DATABASE=root
    - MYSQL_ROOT_PASSWORD=root
    ports:
    - 3306:3306
    volumes:
    - ./../db:/var/lib/mysql
  redis:
    image: redis:alpine
    restart: always
    ports:
    - 6379:6379

  fpm:
    build: .
    restart: always
    environment:
`env_generator $APPNAME_FPM`
    links:
      - redis
      - db
    ports:
      - 6985:80
    command: "php-fpm"
    volumes:
    - .:/var/www


  scheduler:
    build: .
    restart: always
    environment:
`env_generator $APPNAME_FPM`
    links:
      - redis
      - db
    command: "schedule"

  queue:
    build: .
    restart: always
    environment:
`env_generator $APPNAME_FPM`
    links:
      - redis
      - db
    command: "schedule"
EOL
docker-compose up --build -d $@

