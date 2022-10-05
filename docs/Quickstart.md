
# Quickstart

*How to quickly try out **Danbooru**.*

<br>

## Basic

Run the following to start a basic instance:

```sh
curl -sSL https://raw.githubusercontent.com/danbooru/danbooru/master/bin/danbooru | sh
```

<br>
<br>

## Explanation

This will install **[Docker Compose]**, use it to start **Danbooru** <br>
and once done, be available at  [`http://localhost:3000`][Localhost]

<br>
<br>

## Alternative

If you have **Docker Compose** already installed, <br>
you can use the following commands instead:

```sh
wget https://raw.githubusercontent.com/danbooru/danbooru/master/docker-compose.yaml
```

```sh
docker-compose up
```

<br>


<!----------------------------------------------------------------------------->

[Docker Compose]: https://docs.docker.com/compose/
[Localhost]: http://localhost:3000
