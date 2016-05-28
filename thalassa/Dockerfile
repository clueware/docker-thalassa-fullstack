FROM node:5-slim

MAINTAINER Stéphane Rondinaud

# Python is required for thalassa
RUN apt-get update
RUN apt-get install -y --no-install-recommends python

# Thalassa install
RUN npm install -g thalassa

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Dedicated user
RUN useradd -M -r thalassa

EXPOSE 5001 9000

CMD ["su","-l","thalassa","-c","thalassa-server --debug --redisHost redis --redisPort 6379"]
