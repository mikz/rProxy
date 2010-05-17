#!/usr/bin/env rackup -Ilib:../lib -s thin

require "rproxy"

run RProxy::Server.new