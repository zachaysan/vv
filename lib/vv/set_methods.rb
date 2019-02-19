module VV

  module SetMethods

    def self.included(base)
      base.extend(ClassMethods)
      base.include(SetAndArrayMethods)
    end

    module ClassMethods

      def vv_included?
        true
      end

    end

    module SetAndArrayMethods

      def gravify
        self.collect do |elem|
          "`#{elem}`"
        end
      end

      def gravify!
        self.collect! do |elem|
          "`#{elem}`"
        end
      end

      def includes! other
        return if self.include? other
        fail "Collection does not include `#{other}`."
      end
      alias_method :include!, :includes!

      def includes_one?(other)
        ok_type   = other.is_a? Array
        ok_type ||= other.is_a? Set

        fail TypeError, "Expecting array" unless ok_type

        ( self & other ).one?
      end
      alias_method :include_one?, :includes_one?

      def includes_one!(other)
        return true if includes_one? other
        message = "Collections did not share exactly one element."
        fail message
      end
      alias_method :include_one!, :includes_one!

      def includes_any?(other)
        ok_type   = other.is_a? Array
        ok_type ||= other.is_a? Set

        fail TypeError, "Expecting array" unless ok_type
        ( self & other ).any?
      end
      alias_method :include_any?, :includes_any?

      def includes_any! other
        return true if includes_any? other
        message = "Collections did not share exactly any elements."
        fail message
      end
      alias_method :include_any!, :includes_any!

      def stringify_collection grave: false
        return self.gravify.stringify_collection if grave

        return String.empty_string if self.blank?
        return self.first          if self.size == 1
        return self.join " and "   if self.size == 2

        new_collection = self[0..-3]
        back_fragment  = self[-2..-1].join ", and "
        new_collection << back_fragment
        new_collection.join ", "
      end

    end

  end

end
