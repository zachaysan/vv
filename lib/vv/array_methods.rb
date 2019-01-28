module VV
  module ArrayMethods

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def vv_included?
        true
      end

    end

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

    def includes_any?(other)
      raise TypeError, "Expecting array" unless other.is_a? Array
      uother = other.uniq
      uself  = self.uniq
      (uself + uother).uniq.size < (uself.size + uother.size)
    end

    def include_any?(other)
      self.includes_any?(other)
    end

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

    def spaced
      self.join(" ")
    end

    def format!(other)
      self.spaced.format! other
    end

    def second
      self[1]
    end

    def third
      self[2]
    end

    def fourth
      self[3]
    end

    def fifth
      self[4]
    end

    def sixth
      self[5]
    end

    def seventh
      self[6]
    end

    def eighth
      self[7]
    end

    def ninth
      self[8]
    end

    def tenth
      self[9]
    end

  end

end
