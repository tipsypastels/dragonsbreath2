require 'zeitwerk'
require 'active_support/all'

loader = Zeitwerk::Loader.new
loader.push_dir('src')
loader.setup