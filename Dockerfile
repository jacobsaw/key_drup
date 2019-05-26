FROM drupal:8-apache

RUN apt-get update && apt-get install -y \
	curl \
	git \
	mysql-client \
	vim \
	wget

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
	php composer-setup.php && \
	mv composer.phar /usr/local/bin/composer && \
	php -r "unlink('composer-setup.php');"

RUN composer global require consolidation/cgr

ENV PATH="/root/.composer/vendor/bin:${PATH}"

RUN cgr drush/drush

RUN rm -rf /var/www/html/*

ENV APACHE_DOCUMENT_ROOT=/var/www/html/drupal
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

WORKDIR /var/www/html

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
RUN sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 8M/g' $PHP_INI_DIR/php.ini

COPY html .

RUN composer install

RUN cp settings.php drupal/sites/default/settings.php

RUN chmod a-w drupal/sites/default/settings.php
