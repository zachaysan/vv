module VV

  module ObjectMethods

    alias_method :responds_to?, :respond_to?

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

  end
end
