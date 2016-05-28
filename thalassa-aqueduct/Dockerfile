FROM node:5-slim

MAINTAINER Stéphane Rondinaud

# Python is required for thalassa
RUN apt-get update
RUN apt-get install -y --no-install-recommends python

# Installing thalassa-aqueduct
# Build essentials for building binary packages - second step as to factorize thalassa docker image
RUN apt-get install -y --no-install-recommends build-essential

# Thalassa Aqueduct install
RUN npm install -g thalassa-aqueduct

# Build Cleanup
RUN apt-get purge -y --auto-remove build-essential

# Installing haproxy
RUN apt-get install -y --no-install-recommends haproxy

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Dedicated user
RUN useradd -M -r thalassa

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 10000

ENTRYPOINT ["/docker-entrypoint.sh"]
