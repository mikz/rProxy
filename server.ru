#!/usr/bin/env rackup -Ilib:../lib -s thin
require "server"
require "plugin"

run RProxy::Server.new