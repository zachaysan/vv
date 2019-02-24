module VV
  module IntegerMethods

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def vv_included?
        true
      end

    end

    def spaces
      characters String.space
    end

    def dashes
      characters String.dash
    end

    def characters character, fail_on_negative: false
      message = "Expected single character, not #{character}."
      fail ArgumentError, message if character.length > 1

      message = "Expected non-negative integer, not `#{self}`."
      fail message if self < 0 and fail_on_negative

      ( self > 0 ) ? ( character * self ) : String.empty_string
    end

    def to_i!
      self
    end

  end
end
