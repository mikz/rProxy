#!/usr/bin/env rackup
$:.unshift File.dirname(__FILE__)
$:.unshift File.dirname(__FILE__)+"lib"

require "rproxy"
run RProxy::Server
