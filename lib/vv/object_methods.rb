module VV

  module ObjectMethods

    alias_method :responds_to?, :respond_to?

    def consider input, &block
      @__vv_consideration_dismissed_level ||= false

      # For a potential parent consideration
      return if self._consideration_dismissed?

      @__vv_consideration_others ||= Hash.new
      @__vv_consideration_level  ||= -1
      @__vv_consideration_level   +=  1

      @__vv_considerations ||= Array.new
      @__vv_considerations << input
      yield
    ensure
      if @__vv_consideration_dismissed_level == \
         @__vv_consideration_level
        remove_instance_variable :@__vv_consideration_dismissed_level
      end

      @__vv_consideration_level -= 1
      if @__vv_consideration_level < 0
        remove_instance_variable :@__vv_consideration_level
        remove_instance_variable :@__vv_consideration_others
      end
      @__vv_considerations.pop
      unless @__vv_considerations.any?
        remove_instance_variable :@__vv_considerations
      end
    end

    def given potential_match
      return if self._consideration_dismissed?
      return unless potential_match == self._consideration

      response = yield
      self._dismiss_consideration
      response
    end

    def within potential_enum
      return if self._consideration_dismissed?

      return unless potential_enum.include? self._consideration
      response = yield
      self._dismiss_consideration
      response
    end

    def otherwise
      self._ensure_consideration_level!

      level   = @__vv_consideration_level
      message = "Multiple otherwise methods in consideration."
      fail message if @__vv_consideration_others[level]
      @__vv_consideration_others[level] = true

      return if self._consideration_dismissed?

      response = yield
      self._dismiss_consideration
      response
    end

    def set_attrs_via( *attributes, document: )
      attributes.flatten!
      document.keys.to_set.includes_all! attributes
      attributes.each do |attribute|
        value  = document.fetch(attribute)
        setter = attribute.setter_sym
        insta  = attribute.insta_sym
        if self.respond_to? setter
          self.public_send setter, value
        else
          self.instance_variable_set insta, value
        end
      end
    end

    def blank?
      respond_to?(:empty?) ? !!empty? : !self
    end unless method_defined? :blank?

    def cli_printable **kwargs
      String.get_stdout { self.cli_print( **kwargs ) }
    rescue NoMethodError
      message = \
      "`cli_printable` requires `cli_print` on child class"
      fail NoMethodError, message
    end unless method_defined? :cli_printable

    def present?
      !blank?
    end unless method_defined? :present?

    def one_of? *collection, mixed: false, allow_unsafe: false
      nested   = collection.first.is_a? Array
      nested ||= collection.first.is_a? Hash
      nested ||= collection.first.is_a? Set

      message = \
      "Unexpected nested argument. If desired set `allow_unsafe: true`."
      fail ArgumentError, message if nested unless allow_unsafe

      return collection.include? self if mixed

      klass = self.class
      ok = collection.reject {|s| s.is_a? klass }.blank?

      message = "Invalid types: #{klass} collection required."
      fail ArgumentError, message unless ok

      collection.include? self
    end

    def one_of! *collection, mixed: false
      return true if self.one_of?( *collection, mixed: mixed )

      klass = self.class
      collection = collection.stringify_collection grave: true
      message = "#{klass} `#{self}` is invalid. Must be one of: #{collection}."
      fail message
    end

    def is_a! klass
      message = \
      "Expected `#{klass}` instance, not `#{self.class}`."
      fail ArgumentError, message unless self.is_a? klass
    end
    alias_method :must_be_a!, :is_a!

    def _dismiss_consideration
      self._ensure_consideration_level!
      @__vv_consideration_dismissed_level = \
      @__vv_consideration_level
    end

    def _consideration_dismissed?
      defined = \
      instance_variable_defined?("@__vv_consideration_dismissed_level")

      message = \
      "Assertion failure: @__vv_consideration_dismissed_level not defined"
      fail message unless defined

      !! @__vv_consideration_dismissed_level
    end

    def _ensure_consideration_level!
      defined = instance_variable_defined?("@__vv_considerations")
      fail "No current consideration active" unless defined

      defined = instance_variable_defined?("@__vv_consideration_level")
      message = "Assertion failure: Consideration level not set"
      fail message unless defined

      message = \
      "Assertion failure: Consideration level mismatch."
      size = @__vv_considerations.size
      level_ok = size == ( @__vv_consideration_level + 1 )
      fail message unless level_ok
    end

    def _consideration
      self._ensure_consideration_level!
      @__vv_considerations.last
    end

  end
end
