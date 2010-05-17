module Debugging
  COLORS = {:name => :green, :value => :yellow, :title => :blue}
  def DEBUG *args, &block
    #return if !Rails.env.development? && args.last != true
    
    messages = ["#{color "Debugging output", COLORS[:title]}:"]
    
    context = block.binding if block_given?
    block.call.each do |arg|
      messages << %{#{color arg, COLORS[:name]}: #{color (eval arg, context).inspect, COLORS[:value]}}
    end if context
    args.each do |arg|
      messages << %{#{color arg.class, COLORS[:name]}: #{color arg.inspect, COLORS[:name]}}
    end
    #Rails.logger.debug
    STDERR << "\n"+messages.join("\n\t") + "\n"
  end
  alias_method :D, :DEBUG
  
  private
  def color text, color
    if true #ActiveRecord::Base.colorize_logging
      ColorString.new(text.to_s).send(color)
    else
      text
    end
  end
  class ColorString < String
    def red; colorize(text, "\e[1m\e[31m"); end
    def green; colorize(self, "\e[1m\e[32m"); end
    def dark_green; colorize(self, "\e[32m"); end
    def yellow; colorize(self, "\e[1m\e[33m"); end
    def blue; colorize(self, "\e[1m\e[34m"); end
    def dark_blue; colorize(self, "\e[34m"); end
    def pur; colorize(self, "\e[1m\e[35m"); end
    def colorize(text, color_code)  "#{color_code}#{text}\e[0m" end
  end
end

include Debugging