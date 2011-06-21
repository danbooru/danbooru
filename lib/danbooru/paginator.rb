require "danbooru/paginator/active_record_extension"
require "danbooru/paginator/collection_extension"
require "danbooru/paginator/numbered_collection_extension"
require "danbooru/paginator/sequential_collection_extension"

ActiveRecord::Base.__send__(:include, Danbooru::Paginator::ActiveRecordExtension)
