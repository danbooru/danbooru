ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'bootsnap'
require 'tmpdir'
Bootsnap.setup(
  cache_dir: File.join(Dir.tmpdir, 'bootsnap-cache'), # Path to your cache
  development_mode: ENV['MY_ENV'] == 'development',
  load_path_cache: true, # Should we optimize the LOAD_PATH with a cache?
  autoload_paths_cache: true, # Should we optimize ActiveSupport autoloads with cache?
  disable_trace: false, # Sets `RubyVM::InstructionSequence.compile_option = { trace_instruction: false }`
  compile_cache_iseq: true, # Should compile Ruby code into ISeq cache?
  compile_cache_yaml: true # Should compile YAML into a cache?
)
