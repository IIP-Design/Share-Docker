FROM php:5.6-apache

# Install software deps
RUN apt-get update && apt-get install -y libpng12-dev libjpeg-dev git vim && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install gd mysqli


# Enable Apache modules
RUN a2enmod rewrite expires


# Setup Apache config
COPY apache.conf/000-default.conf /etc/apache2/sites-enabled/000-default.conf


# Environmental variables for Wordpress
ENV WORDPRESS_VERSION 4.5.3
ENV WORDPRESS_SHA1 835b68748dae5a9d31c059313cd0150f03a49269
ENV WEBROOT_REPO https://github.com/USStateDept/ShareAmerica.git


# Clone repo
# Download Wordpress and compare checksums
# Setup Wordpress webroot directory in /usr/src
RUN git clone ${WEBROOT_REPO} /usr/src/wordpress \
    && curl -o wordpress.tar.gz -SL https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz \
    && echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c - \
    && tar -xzf wordpress.tar.gz -C /usr/src/wordpress \
    && rm wordpress.tar.gz \
    && mv /usr/src/wordpress/wordpress /usr/src/wordpress/wp \
    && mv /usr/src/wordpress/wp/wp-content /usr/src/wordpress/wp-content \
    && cp /usr/src/wordpress/.htaccess /usr/src/wordpress/wp/.htaccess \
    && chown -R www-data:www-data /usr/src/wordpress


# Move Wordpress directory from /usr/src to /var/www/html
RUN tar cf - --one-file-system -C /usr/src/wordpress . | tar xf - -C /var/www/html \
    && git checkout 0.0.1


# Cleanup
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
