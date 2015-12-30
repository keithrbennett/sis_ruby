
# Takes methods and builds an internal hash where the method calls
# are keys, and their parameter is the value.
class HashBuilder

  attr_reader :key_type

  def initialize(key_type = String)
    raise ArgumentError.new("Invalid key type '#{key_type}'") unless [String, Symbol].include?(key_type)
    @key_type = key_type
    @data = {}
  end


  def method_missing(method_name, *args)
    value = args.first
    key = (@key_type == String) ? method_name.to_s : method_name.to_sym
    @data[key] = value
    self
  end


  def respond_to_missing?(method_name, include_private)
    true  # TODO: exclude ancestor methods?
  end


  def to_h
    @data
  end
end