# ShareAmerica Docker DevBox

A working proof of concept for using Docker + Wordpress for a local development environment.

## Dependencies

1. Nginx - A reverse proxy so that you don't have to specify a port in the `wp-config.php` file
2. [Official PHP-Apache Docker Image](https://hub.docker.com/_/php/)
3. [docker-volume-container-rsync](https://git.io/v6foi) - To create an external volume for `/var/www/html`

## Rough Setup

First, you'll need to edit your `/etc/hosts` file to route your fake domain to `127.0.0.1`, e.g.:

    127.0.0.1 localhost share.america.dev

You need to setup Nginx via Homebrew as described in this [gist](https://gist.github.com/natchiketa/987524a561e892924e81), though your nginx.conf will differ a little. See `/nginx/nginx.conf`.

Create a Docker image from the [rsync-volume](https://github.com/NathanKleekamp/rsync-volume) repo.

    docker build -t rsync .

Then create the `sharevolume`:

    docker run -p '10873:873' -v sharevolume:/var/www/html --name sharevolume -d rsync

rsync the files from your the host machine to the volume. It's easier if you have that directory setup from the beginning with `wp/` and `/wp-content` dirs.

    rsync --delete -avP /path/to/files/ rsync://0.0.0.0:10873/volume

Start up the wordpress and mysql containers in daemon mode:

    docker-compose up -d

Import the db

    mysql -u root -h 0.0.0.0 -P 33309 wordpress < share.sql -p

Change the appropriate urls in the appropriate tables to point from production to dev.

Reload the share.america.dev

You can use something like [Filewatch](https://github.com/thomasfl/filewatcher) to keep the rsync volume up-to-date with your changes.
