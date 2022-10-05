
<br>

<div align = center>

[![Badge Discord]][Discord]   
[![Badge Codecov]][Codecov]

<br>
<br>

<img
    src = 'public/favicon.svg'
    width = 120
/>

# Danbooru

*A taggable image board written in Rails.*

<br>
<br>

<img
    src = 'docs/Preview.png'
    width = 600
/>

</div>


## Quickstart

Run this to start a basic Danbooru instance:

```sh
curl -sSL https://raw.githubusercontent.com/danbooru/danbooru/master/bin/danbooru | sh
```

This will install [Docker Compose](https://docs.docker.com/compose/) and use it
to start Danbooru. When it's done, Danbooru will be running at http://localhost:3000.

Alternatively, if you already have Docker Compose installed, you can just do:

```sh
wget https://raw.githubusercontent.com/danbooru/danbooru/master/docker-compose.yaml
docker-compose up
```

<br>


<!----------------------------------------------------------------------------->

[Codecov]: https://codecov.io/gh/danbooru/danbooru
[Discord]: https://discord.gg/eSVKkUF


<!---------------------------------[ Badges ]---------------------------------->

[Badge Codecov]: https://img.shields.io/codecov/c/gh/danbooru/danbooru?logo=codecov&logoColor=white&style=for-the-badge&labelColor=F01F7A&color=be1963
[Badge Discord]: https://img.shields.io/discord/310432830138089472?label=Discord&style=for-the-badge&labelColor=6e85d2&color=5a6dac
