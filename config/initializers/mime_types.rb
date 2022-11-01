# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
Mime::Type.register_alias "application/xml", :sitemap

# XXX remove after upgrading to rack 3.0.0.
Mime::Type.register "image/webp", :webp
Mime::Type.register "image/avif", :avif
