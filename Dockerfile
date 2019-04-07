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

ENV APACHE_DOCUMENT_ROOT=/var/www/html/src/web
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

WORKDIR /var/www/html
RUN git clone https://github.com/jacobsaw/key_drup_composer.git src
WORKDIR /var/www/html/src
RUN composer install
