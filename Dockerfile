FROM php:7.4-apache
WORKDIR /var/www/html

ENV ACCEPT_EULA=Y

LABEL version="1.017b-beta"
LABEL description="PHP Image for Omaka-s Open CMS"
LABEL maintainer="Chris Howatt <chowatt@galencollege.edu>"

# Fix debconf warnings upon build
ARG DEBIAN_FRONTEND=noninteractive

# Install selected extensions and other stuff
RUN apt-get update \
    && apt-get -y --no-install-recommends install apt-utils libxml2-dev gnupg apt-transport-https ldb-dev libldap openldap-dev gnupg \
    && libc-client-dev libkrb5-dev libxml2-dev libbz2-dev zlib1g-dev libpng-dev libicu-dev libldap2-dev vim \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Install git
RUN apt-get update \
    && apt-get -y install git wget \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/g/glibc/multiarch-support_2.27-3ubuntu1.5_amd64.deb \
    && apt-get install ./multiarch-support_2.27-3ubuntu1.5_amd64.deb \
    && rm multiarch-support_2.27-3ubuntu1.5_amd64.deb

# Install MS ODBC Driver for SQL Server / PHP Extensions
RUN apt-get update \
    && apt-get -y install libldb-dev libldap2-dev libicu-dev libzip-dev zip zlib1g-dev libpng-dev libzip-dev libodbc1\
    && docker-php-ext-install pdo_mysql ldap intl zip gd \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN apt-get update \
    && apt-get install -y rsync \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN curl https://getcomposer.org/installer | php && mv composer.phar /bin/composer
WORKDIR /tmp
RUN wget https://github.com/omeka/omeka-s/releases/download/v3.2.2/omeka-s-3.2.2.zip \
    && unzip omeka-s-3.2.2.zip \
    && rsync -a omeka-s/ /var/www/html \
    && rm -rf /tmp/* \
    && chmod -R 770 /var/www/html \
    && chown -R www-data /var/www/html

WORKDIR /var/www/html

RUN a2enmod rewrite
