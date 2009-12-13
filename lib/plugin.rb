require 'nokogiri'
require 'digest/sha2'
require 'ezcrypto'
require 'base32'
require "openssl"
require "sequel"
require 'open-uri'

require "db"

module Plugin
end

module RProxy
  class Plugin < Sequel::Model
    
    def url_for_user user
      user.encrypt_url self.id, self.url
    end
    def worker thing, user, base_url, app_path
      @worker = Worker.new(thing, user, base_url, app_path, self)
    end
    
    class Worker
      include Nokogiri
      attr_accessor :request, :response, :plugin
      attr_reader :document
      INVALID_LINKS = ["http://","https://","javascript:","mailto:","#"]
      INVALID_LINK = /^(((http|https)\:\/\/)|((javascript|mailto)\:)|\#)/i
      PARSER_OPTIONS = XML::ParseOptions::DEFAULT_XML | XML::ParseOptions::STRICT
      SERIALIZE_OPTIONS = XML::Node::SaveOptions::AS_XHTML
      def initialize thing, user, base_url, app_path, plugin
        @document = Nokogiri::XML(thing)
        @user = user
        @url = base_url
        @app_path = app_path
        @plugin = plugin

        add_base_tag
        replace_links

      end
    
    
      def to_s
        return nil unless @document
        @document.serialize
      end
    
      private
      def add_base_tag
        base = XML::Node.new "base", @document
        base["href"] = @url.to_s
        @document.xpath("//xmlns:head", "xmlns" => @document.namespaces['xmlns']).children.first.add_previous_sibling base
      end
      def replace_links
        @document.xpath('//xmlns:a[@href] | //xmlns:form[@action]', "xmlns" => @document.namespaces['xmlns']).each do |node|
          case node.name
            when "a"
              node['href'] = @app_path.merge("/p/" + @user.encrypt_url(@plugin.id, @url.merge(node['href']))).to_s unless node['href'] =~ INVALID_LINK
            when "form"
              node['action'] = @app_path.merge("/p/" + @user.encrypt_url(@plugin.id, @url.merge(node['action']), node['method'] || "GET")).to_s
          end
        end
      end
    end
  end
end

Dir["plugins/*.rb"].each do |plugin|
  require plugin
end