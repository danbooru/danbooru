#!/bin/env ruby

require 'mkmf'

CONFIG['CC'] = "g++"
CONFIG['LDSHARED'] = CONFIG['LDSHARED'].sub(/^cc /,'g++ ')	# otherwise we would not link with the C++ runtime

dir_config("gd")
dir_config("jpeg")
dir_config("png")

have_header("gd.h")

have_library("gd")
have_library("jpeg")
have_library("png")

have_func("gdImageCreateFromGif", "gd.h")
have_func("gdImageJpeg", "gd.h")
have_func("jpeg_set_quality", ["stdlib.h", "stdio.h", "jpeglib-extern.h"])
have_func("png_set_expand_gray_1_2_4_to_8", "png.h")

with_cflags("-O2 -fno-exceptions -Wall") {true}
#with_cflags("-O0 -g -fno-exceptions -Wall") {true}

create_makefile("danbooru_image_resizer")
