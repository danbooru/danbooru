Gem::Specification.new do |s|
  s.name        = 'imagesize'
  s.description = 'measure image size(GIF, PNG, JPEG ,,, etc) code by Pure Ruby'
  s.summary     = 'Imagesize will detect and measure images in the following formats: GIF, PNG, JPEG, BMP, PPM, PGM, PBM, XBM, TIFF, XPM, PSD, SWF'

  s.version = '0.1.2'
  s.date    = '2010-10-02'

  s.author   = 'Keisuke Minami'
  s.email    = 'keisuke@rccn.com'
  s.homepage = 'http://rubygems.org/gems/imagesize'

  s.files        = `git ls-files`.split("\n")
  s.require_path = 'lib'
end
