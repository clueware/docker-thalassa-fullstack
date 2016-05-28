# Thalassa/Thalassa Aqueduct+HAProxy running in Docker

> A complete [Thalassa](https://github.com/PearsonEducation/thalassa)/[Thalassa Aqueduct](https://github.com/PearsonEducation/thalassa-aqueduct) stack.

This project provides a [Docker Compose](https://docs.docker.com/compose/) environment that runs [Thalassa](https://github.com/PearsonEducation/thalassa) and a matching [Thalassa Aqueduct](https://github.com/PearsonEducation/thalassa-aqueduct) instance.

In a nutshell, it offers dynamic control of a HAproxy instance, complete with server registration and a web ui for status monitoring.

## Getting started

Everything is set up in the docker-compose.yml file. A simple

```shell
docker-compose up
```

should be enough to get you started.

## Exposing proxied services

As the goal is to expose some network services, you'll want to expose the ports that HAproxy will be proxying.
At the end of docker-compose.yml, you'll find the following comment:

```yml
<...>
ports:
  # the API/web ui port, used for front/back-ends configuration
  - 10000:10000
  # here you should add the ports mapping for the services you plan
  # to proxy
```

As an example, if you plan to proxy MySQL instances (port 3306) and a web application (port 80), you should change it into:

```yml
    ports:
      # the API/web ui port, used for front/back-ends configuration
      - 10000:10000
      # mysql
      - 3306:3306
      # webapp
      - 80:80
```

Remember: these ports are HAproxy entrypoints ports, not the proxied ports.

## Declaring the frontends

Frontends are the entrypoints of your proxied services - and should be exposed as previously shown.

Their creation is done against Thalassa Aqueduct component - exposed on port 10000 of your docker instance.

You'll find a proper [example](https://github.com/PearsonEducation/thalassa-aqueduct#put-frontendskey) in Thalassa Aqueduct README.

To follow up on the previous example, you'd declare two frontends:

*   one for the MySQL service
*   one for the web application service

### The MySQL frontend

Let's do it with curl:

```shell
curl -H "Content-type: application/json" -X PUT -d '{ "bind": "*:3306", "backend": "mysql-backend", "mode": "tcp"}' http://localhost:10000/frontends/mysql-frontend
```

### The webapp frontend

```shell
curl -H "Content-type: application/json" -X PUT -d '{ "bind": "*:80", "backend": "webapp-backend", "mode": "http"}' http://localhost:10000/frontends/webapp-frontend
```

## Declaring the backends

Backends pool together a set of servers - or members as Thalassa calls them.

Their creation is done against Thalassa Aqueduct component - exposed on port
10000 of your docker instance.

Again, you'll find a proper [example](https://github.com/PearsonEducation/thalassa-aqueduct#put-backendskey)
in Thalassa Aqueduct README.

For our example, you'll declare two backends matching the two backends:

*   one for the MySQL servers
*   one for the web application servers

### The MySQL backend

```shell
curl -H "Content-type: application/json" -X PUT -d '{ "type":"dynamic", "name":"mysql-backend", "version":"1.0.0","balance":"source", "mode":"tcp","natives":["option mysql-check"]}' http://localhost:10000/backends/mysql-backend
```

### The web app backend

```shell
curl -H "Content-type: application/json" -X PUT -d '{ "type":"dynamic", "name":"webapp-backend", "version":"1.0.0","balance":"source", "mode":"tcp","health":{"interval":"5000"}}' http://localhost:10000/backends/webapp-backend
```

## Server registration

Now that we have a frontend and a backend, for each service, we need to register the servers that will provide the service.

The server registration is done against Thalassa component - exposed on port 9000 of your docker instance.

### Registering a new MySQL server

For the moment, Aqueduct UI should show you an empty MySQL backend.

Registering a new server is quite straightforward:

```shell
curl -H "Content-type: application/json" -X POST -d '{ "secondsToExpire":"10000"}' http://localhost:9000/registrations/mysql-backend/1.0.0/10.0.0.1/3306
```

Please note that:
*   the "secondsToExpire" is the amount of seconds this registration is valid.
   The best way to maintain a registration is for the server to register itself one the service is activated and then periodically refresh its registration as long as the service is running.
   It allows for rolling upgrades and can substitute a HAproxy health check when the latter does not support the proxied service natively.
*   the registration URI is in the form [http://localhost:9000/registrations/\[backend name\]/\[version\]/\[server\]/\[port\]]()
where:
  *   the \[backend name\] is the one against which you're registering a server
  *   the \[version\] should match the version served by the registered server. This version is to be understood as your application version, not MySQL version
  *   the \[server\] and \[port\] values are the obviously the one to be registered to the backend

Given that we're running everything in Docker, take great care that the servers can be joined from the thalassa-aqueduct container.

If you have a look at Aqueduct UI, you should now see a new member on the mysql-backend, with the given IP - and a "down" status, except if you have a MySQL server running at 10.0.0.1!

### Registering a new webapp server

Registering a new webapp server is similar to a mysql one - just make sure you register it to the proper backend.

```shell
curl -H "Content-type: application/json" -X POST -d '{ "secondsToExpire":"10000"}' http://localhost:9000/registrations/webapp-backend/1.0.0/10.0.1.1/8080
```

As you can see in this example, the server can use any port on the backend: HAproxy will expose the service on its configured frontend port.

## Licensing

The code in this project is licensed under MIT license.
