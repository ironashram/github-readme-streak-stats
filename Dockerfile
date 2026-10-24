FROM alpine:3.24

RUN apk upgrade --no-cache && \
    apk add --no-cache \
    apache2 \
    php85 \
    php85-apache2 \
    php85-curl \
    php85-intl \
    php85-phar \
    php85-openssl \
    php85-mbstring \
    php85-iconv \
    php85-ctype \
    icu-data-full \
    inkscape \
    font-dejavu \
    curl && \
    ln -sf /usr/bin/php85 /usr/bin/php && \
    sed -i -e 's|^#LoadModule rewrite_module|LoadModule rewrite_module|' \
    -e 's|^#LoadModule headers_module|LoadModule headers_module|' \
    -e 's|^ServerTokens .*|ServerTokens Prod|' \
    -e 's|^ServerSignature .*|ServerSignature Off|' \
    -e 's|^ErrorLog .*|ErrorLog /dev/stderr|' \
    -e 's|^\(\s*\)CustomLog .*|\1CustomLog /dev/stdout combined|' \
    /etc/apache2/httpd.conf

COPY --from=composer/composer:latest-bin@sha256:016c41066558559142758092f7ef286d66ae113df23d49e086fdda0166dd5f01 /composer /usr/bin/composer

WORKDIR /var/www/html

COPY composer.json composer.lock ./
COPY src/ ./src/
RUN composer install --no-dev --optimize-autoloader --no-scripts

COPY <<'EOF' /etc/apache2/conf.d/zz-streak.conf
ServerName localhost
PassEnv TOKEN
PassEnv WHITELIST
<VirtualHost *:80>
    DocumentRoot /var/www/html/src
    <Directory /var/www/html/src>
        Options -Indexes
        AllowOverride None
        Require all granted
        DirectoryIndex index.php
        Header always set Access-Control-Allow-Origin "*"
        Header always set Content-Type "image/svg+xml" "expr=%{REQUEST_URI} =~ m#\.svg$#i"
        Header always set Content-Security-Policy "default-src 'none'; style-src 'unsafe-inline'; img-src data:;" "expr=%{REQUEST_URI} =~ m#\.svg$#i"
        Header always set Referrer-Policy "no-referrer-when-downgrade"
        Header always set X-Content-Type-Options "nosniff"
    </Directory>
</VirtualHost>
EOF

RUN mkdir -p /var/www/html/cache && \
    chown -R apache:apache /var/www/html && \
    find /var/www/html -type d -exec chmod 755 {} \; && \
    find /var/www/html -type f -exec chmod 644 {} \; && \
    chmod 775 /var/www/html/cache

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/demo/ || exit 1

EXPOSE 80

CMD ["httpd", "-D", "FOREGROUND"]
