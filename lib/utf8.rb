module UTF8Attributes
  def self.included(base)
    base.class_eval %{
      alias_method :attribute_set_without_encoding, :attribute_set
      alias_method :attribute_set, :attribute_set_with_encoding
      alias_method :[]=, :attribute_set
    }
  end

  def attribute_set_with_encoding(name, value)
    value.force_encoding(Encoding::UTF_8) if value.is_a?(String)
    attribute_set_without_encoding(name, value)
  end
  
end