require 'rubygems'
require "bundler"

require 'async-rack'

Encoding.default_internal = 'UTF-8'
Encoding.default_external = 'UTF-8'



require "lib/debugging"


require "lib/plugin"


require "lib/server"

require 'lib/inflections'