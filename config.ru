#!/usr/bin/env rackup -Ilib:../lib

require "rproxy"
RProxy::Server.run!(:port => 9090)
