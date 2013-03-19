= image_size -- measure image size(GIF, PNG, JPEG ,,, etc)

measure image (GIF, PNG, JPEG ,,, etc) size code by Pure Ruby
["PSD", "XPM", "TIFF", "XBM", "PGM", "PBM", "PPM", "BMP", "JPEG", "PNG", "GIF", "SWF"]

== Download

The latest version of image_size can be found at

* http://rubyforge.org/frs/?group_id=3460

== Installation

=== Normal Installation

You can install image_size with the following command.

  % ruby setup.rb

from its distribution directory.

=== GEM Installation

Download and install  image_size with the following.

   gem install imagesize

== image_size References

* image_size Project Page: http://rubyforge.org/projects/imagesize
* image_size API Documents: http://imagesize.rubyforge.org

== Simple Example

  ruby "rubygems" # you use rubygems
  ruby "image_size"
  ruby "open-uri"
  open("http://www.rubycgi.org/image/ruby_gtk_book_title.jpg", "rb") do |fh|
    p ImageSize.new(fh.read).get_size
  end

== Licence

This code is free to use under the terms of the Ruby's licence.

== Contact

Comments are welcome. Send an email to "Keisuke Minami":mailto:keisuke@rccn.com

