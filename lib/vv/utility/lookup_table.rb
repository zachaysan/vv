class LookupTable

  attr_reader :canonnicals, :aliases, :data

  def initialize
    @canonicals = Hash.new
    @aliases = Hash.new
    @data = Hash.new
  end

  def alias( key:, to: )
    _ensure_alias_possible key

    @canonicals[key] = to

    @aliases[to] ||= Set.new
    @aliases[to] << key
  end

  def []= key, value
    @data[ self.canonical key ] = value
  end

  def [] key
    @data[ self.canonical key ]
  end

  def canonical key
    @canonicals[key] || key
  end

  def canonical_keys
    @data.keys + (@aliases.keys - @data.keys)
  end

  def include? key
    @data.include?( self.canonical key )
  end

  def to_h
    keys = self.canonical_keys

    keys.inject({}) {|acc, key|
      data     = @data[key]    || {}
      aliases  = @aliases[key] || {}
      acc[key] = { data: data, aliases: aliases.to_a }
      acc
    }
  end

  # Make Object class method called `delegate_missing`?
  def method_missing(method, *args, **kwargs, &block)
    super
  rescue NoMethodError
    begin
      if args.size > 0 && kwargs.size > 0
        return self.to_h.public_send method, *args, **kwargs, &block
      elsif args.size > 0
        return self.to_h.public_send method, *args, &block
      elsif kwargs.size > 0
        return self.to_h.public_send method, **kwargs, &block
      else
        return self.to_h.public_send method, &block
      end
    rescue NoMethodError
    end
    raise
  end

  def lookup_canonical key
    return key if self.canonical_keys.include? key

    @canonicals[key]
  end

  protected

  def _ensure_alias_possible key
    return if @aliases[key].blank?
    aliases = @aliases[key]
    count = aliases.count
    message = \
    "Cannot alias `#{key}` because #{count} others currently alias it."
    fail message
  end

end
