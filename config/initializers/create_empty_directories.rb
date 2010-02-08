require 'fileutils'

FileUtils.mkdir_p("#{Rails.root}/public/data/size_thumbnail")
FileUtils.mkdir_p("#{Rails.root}/public/data/size_medium")
FileUtils.mkdir_p("#{Rails.root}/public/data/size_large")
FileUtils.mkdir_p("#{Rails.root}/public/data/size_original")
