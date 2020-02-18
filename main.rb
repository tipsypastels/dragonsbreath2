require 'zeitwerk'
require 'active_support/all'
require 'securerandom'

loader = Zeitwerk::Loader.new
loader.push_dir('src')
loader.setup