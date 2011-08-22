#!/usr/bin/env ruby

require 'danbooru_image_resizer'
Danbooru.resize_image("jpg", "test.jpg", "test-out.jpg", 2490, 3500, 95)

