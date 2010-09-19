require "config/environment"


if defined?(:Encoding)
  Encoding.default_external = Encoding.default_internal = 'UTF-8' 
end

require "lib/plugin"
require "lib/server"
require 'lib/inflections'



