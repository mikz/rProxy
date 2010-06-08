#!/usr/bin/env rackup -Ilib:../lib

require "rproxy"
run RProxy::Server
