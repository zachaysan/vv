class VV::JSON

  def self.default_max
    1.mebibyte
  end

  def self.generate object,
                    maximum_bytes=nil,
                    **kwargs

    max = maximum_bytes || self.default_max

    generator = self.new( max, **kwargs )
    generator.serialize object
  end

  def initialize maximum_bytes,
                 float_kwargs: nil

    @max = maximum_bytes
    @response = ""
    @float_kwargs = float_kwargs || {}
  end

  def serialize object

    self.check_for_size_failure!

    case object
    when Hash
      @response += "{"

      object.each do |key, value|
        self.serialize! key.to_s
        @response += ":"

        self.serialize! value
        @response += ","
      end

      @response.chomp! ","
      @response += "}"
    when Array
      @response += "["

      object.each do |value|
        self.serialize! value
        @response += ","
      end

      @response.chomp! ","
      @response += "]"
    when String
      self.size_failure! if ( object.size + 2 ) > @max
      @response += object.to_json
    when Float
      @response += object.vv_json( **@float_kwargs )
    else
      if object.respond_to? :vv_json
        @response += object.vv_json
      else
        fail "VV::JSON cannot generate JSON for `#{object.class}`."
      end
    end

    self.check_for_size_failure!

    @response
  end
  alias_method :serialize!, :serialize

  def default_max
    self.class.default_max
  end

  def check_for_size_failure!
    size_failure! if @response.size > @max
  end

  def size_failure!
    if @max == self.default_max
      fail "VV::JSON generation size exceeds default max of 1 MiB"
    else
      fail "VV::JSON generation size exceeds max of `#{@max}` bytes"
    end
  end

end
