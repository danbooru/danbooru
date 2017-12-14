require "danbooru/paginator/active_record_extension"
require "danbooru/paginator/numbered_collection_extension"
require "danbooru/paginator/sequential_collection_extension"
require "danbooru/paginator/pagination_error"

ApplicationRecord.__send__(:include, Danbooru::Paginator::ActiveRecordExtension)
Delayed::Job.__send__(:include, Danbooru::Paginator::ActiveRecordExtension)
