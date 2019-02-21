class LookupTable

  attr_reader :canonnicals,
              :aliases,
              :data,
              :ignore_case

  def initialize ignore_case: false
    @ignore_case = ignore_case
    @canonicals = Hash.new
    @aliases = Hash.new
    @data = Hash.new
  end

  def alias( key:, to: )

    if @ignore_case
      key = key.downcase
      to  =  to.downcase
    end

    return if key == to

    _ensure_alias_possible key

    @canonicals[key] = to

    @aliases[to] ||= Set.new
    @aliases[to] << key
  end

  def []= key, value
    key = key.downcase if @ignore_case
    @data[ self.canonical key ] = value
  end

  def [] key
    key = key.downcase if @ignore_case
    @data[ self.canonical key ]
  end

  def canonical key
    key = key.downcase if @ignore_case
    @canonicals[key] || key
  end

  def canonical_keys
    @data.keys + (@aliases.keys - @data.keys)
  end

  def include? key
    key = key.downcase if @ignore_case
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

  # Because case is ignorable we can't automatically
  # delegate all methods, only those without arguments
  def keys *args, **kwargs, &block
    both = args.present? && kwargs.present?

    return to_h.keys(*args, **kwargs, &block) if both
    return to_h.keys(**kwargs, &block) if kwargs.present?
    return to_h.keys(*args, &block) if args.present?

    to_h.keys( &block )
  end

  def lookup_canonical key
    key = key.downcase if @ignore_case

    return key if self.canonical_keys.include? key

    @canonicals[key]
  end
  alias_method :lookup_key, :lookup_canonical

  def fuzzy_lookup_canonical key
    raise NotImplementedError
    key = key.downcase if @ignore_case
    Dir.glob pattern
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
