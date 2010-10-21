class JrailsGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def copy_js_files
    copy_file 'config/jrails.yml', 'config/jrails.yml'

    prefix = "public/javascripts/"
    ['','min.'].each do |i|
      copy_file "#{prefix}/jquery.#{i}js",          "#{prefix}/jquery.#{i}js"
      copy_file "#{prefix}/jquery-ui.#{i}js" ,      "#{prefix}/jquery-ui.#{i}js"
      copy_file "#{prefix}/jquery-ui-i18n.#{i}js",  "#{prefix}/jquery-ui-i18n.#{i}js"
      copy_file "#{prefix}/jrails.#{i}js",          "#{prefix}/jrails.#{i}js"
    end
  end

end