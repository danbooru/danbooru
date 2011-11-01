#!/usr/bin/env bash

# this should be run after the initial capistrano deployment

mv /var/www/danbooru/public/data/sample /var/www/danbooru/shared/large
mv /var/www/danbooru/public/data/preview /var/www/danbooru/shared/preview
mv /var/www/danbooru/public/data /var/www/danbooru/shared/original
mkdir -p /var/www/danbooru/shared/medium

