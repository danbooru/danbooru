#!/usr/bin/env bash

while true ; do
  script/custom/compile_javascripts ;
  sass public/stylesheets/src/default.scss public/stylesheets/compiled/default.css ;
  sleep 2 ;
done
