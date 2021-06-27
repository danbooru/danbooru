# Logical

This directory contains library code used through Danbooru. This includes things like defining API clients, dealing with
sources, parsing tag searches, storing and resizing images, and so on.

Many of the files here use the Service Object pattern. Instead of putting complex code in models or controllers, it goes
here, in plain old Ruby objects (POROs). This keeps models and controllers simpler, and keeps domain logic isolated and
independent from the database and the HTTP request cycle.

# External links

* https://www.codewithjason.com/rails-service-objects/