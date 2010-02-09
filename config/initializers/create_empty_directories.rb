require 'fileutils'

FileUtils.mkdir_p("#{Rails.root}/public/data/thumb")
FileUtils.mkdir_p("#{Rails.root}/public/data/medium")
FileUtils.mkdir_p("#{Rails.root}/public/data/large")
FileUtils.mkdir_p("#{Rails.root}/public/data/original")
