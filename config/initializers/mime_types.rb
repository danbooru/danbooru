# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
Mime::Type.register_alias "application/xml", :sitemap

# The media types Rails doesn't know about. The types come from the media_file library (see `MediaFile::MIME_TYPES`).
%i[avif swf ugoira].each do |file_ext|
  Mime::Type.register MediaFile::MIME_TYPES.fetch(file_ext), file_ext
end

Mime::Type.register "application/vnd.microsoft.portable-executable", :exe
