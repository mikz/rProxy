module RProxy

  class Ruby < Struct.new(:code)
    VALIDATE = false
  
    def valid?
      check_syntax == :OK
    end
  
    alias :to_str :code
  
    private
    def check_syntax
      return :OK unless VALIDATE
    
      errors = []
      Open3.popen3("ruby -c") do |stdin, stdout, stderr|
        stdin.write(code)
        stdin.close

        errors = stderr.read
      end

      return errors.empty? ? :OK : errors
    end
  end
  
end