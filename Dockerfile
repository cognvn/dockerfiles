FROM mediawiki:1.36

# install additional PHP extensions
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends libpq-dev libhiredis-dev libzip-dev zip; \
  pecl install -o -f redis; \
  docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql; \
  docker-php-ext-install -j "$(nproc)" pgsql pdo pdo_pgsql zip; \
  docker-php-ext-enable redis; \
  rm -r /tmp/pear; \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
  rm -rf /var/lib/apt/lists/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# install additional Mediawiki extensions
RUN mkdir -p /var/www/html/extensions/AWS \
    /var/www/html/extensions/CollapsibleVector \
    /var/www/html/extensions/CollapsibleSections \
    /var/www/html/extensions/HideSidebar; \
  curl -L https://github.com/edwardspec/mediawiki-aws-s3/archive/v0.11.1.tar.gz \
    | tar -xz -C /var/www/html/extensions/AWS --strip-components=1; \
  curl -fsSL https://github.com/wikimedia/mediawiki-extensions-CollapsibleSections/archive/REL1_36.tar.gz \
    | tar -xz -C /var/www/html/extensions/CollapsibleSections --strip-components=1; \
  curl -fsSL https://github.com/wikimedia/mediawiki-extensions-CollapsibleVector/archive/REL1_36.tar.gz \
    | tar -xz -C /var/www/html/extensions/CollapsibleVector --strip-components=1; \
  curl -fsSL https://github.com/mywikis/HideSidebar/archive/main.tar.gz \
    | tar -xz -C /var/www/html/extensions/HideSidebar --strip-components=1

ADD ./composer.local.json /var/www/html/
RUN COMPOSER=composer.local.json composer require --no-update mediawiki/chameleon-skin:~3.0; \
  composer update --no-dev -o

ADD ./LocalSettings.php /var/www/html/
ADD ./cogn.png /var/www/html/resources/assets/

RUN sed -i 's/Listen 80/Listen ${PORT}/' /etc/apache2/ports.conf