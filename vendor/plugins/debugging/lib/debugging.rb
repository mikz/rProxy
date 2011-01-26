module Debugging
  COLORS = {:name => :green, :value => :yellow, :title => :blue}
  def DEBUG *args, &block
    return if !args.last && Rails.env.production?
    
    messages = ["#{color "Debugging output", COLORS[:title]}:"]
    
    context = block.binding if block_given?
    block.call.each do |arg|
      messages << "#{color(arg, COLORS[:name])}: #{awesome_inspect(eval(arg, context))}"
    end if context
    args.each do |arg|
      messages << "#{color(arg.class, COLORS[:name])}: #{awesome_inspect(arg)}"
    end
    
    if Rails.logger
      Rails.logger.debug messages.join("\n\t")
    else
      STDERR << messages.join("\n\t")
    end
  end
  alias_method :D, :DEBUG
  
  def DEBUG! *args, &block
    args << true
    DEBUG *args, &block
  end
  alias_method :D!, :DEBUG!
  
  private
  def color text, color
    if Rails.application.config.colorize_logging
      ColorString.new(text.to_s).send(color)
    else
      text
    end
  end
  
  def awesome_inspect(obj, key = :value)
    (obj.respond_to?(:ai) ? obj.ai : color(obj.inspect, COLORS[key])).to_s
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