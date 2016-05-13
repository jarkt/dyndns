FROM registry.csmk.it/cosmik/web

COPY cosmik /cosmik

RUN chown -R www-data:www-data /cosmik \
	&& apt-get -yq update && apt-get install --no-install-recommends -yq \
	php5.6-xmlrpc \
	&& rm -rf /var/lib/apt/lists/*
