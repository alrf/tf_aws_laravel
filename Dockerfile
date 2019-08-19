FROM alpine:3.10

RUN apk --no-cache add php7 php7-fpm php7-mysqli php7-dba php7-snmp php7-soap php7-bcmath php7-pdo php7-json php7-openssl php7-curl \
	php7-zlib php7-xml php7-phar php7-intl php7-dom php7-xmlreader php7-ctype php7-session \
	php7-mbstring php7-gd php7-tokenizer php7-pdo_mysql nginx supervisor curl && \
	chown -R nobody.nobody /run && \
	chown -R nobody.nobody /var/lib/nginx && \
	chown -R nobody.nobody /var/tmp/nginx && \
	chown -R nobody.nobody /var/log/nginx && \
	mkdir -p /var/www/html

COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY config/php.ini /etc/php7/conf.d/zzz_custom.ini
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

VOLUME /var/www/html

USER nobody

WORKDIR /var/www/html
COPY --chown=nobody app/ /var/www/html/
RUN chmod 755 /var/www/html/storage

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
