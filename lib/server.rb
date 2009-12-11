require 'rubygems'
require 'sinatra/async'
require 'eventmachine'
require "em-http"
require 'nokogiri'
require 'net/http'
require 'uri'

module RProxy
  class Server < Sinatra::Base
  register Sinatra::Async
  
  DOCUMENT = Net::HTTP.get(URI.parse('http://idos.dpp.cz/idos/'))
  enable :show_exceptions
 
  aget '/p/:token' do
    #http = EventMachine::HttpRequest.new('http://idos.dpp.cz/idos/').get :timeout => 5
    #http.callback do
    #  p http.response_header.status
    #  p http.response_header
    #  p http.response
    #  document = Nokogiri::HTML::Document.parse(http.response)
    #  STDERR << %{
    #    #{document.inspect}
    #  }
    #end
    plugin = Plugin.new DOCUMENT
    
    body plugin.to_s
    #end
  end
 
  aget '/delay/:n' do |n|
    EM.add_timer(n.to_i) { body { "delayed for #{n} seconds" } }
  end
 
  aget '/raise' do
    raise 'boom'
  end
  end
end