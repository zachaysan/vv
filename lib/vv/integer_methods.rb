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

    def vv_json
      self.to_json
    end

    def ceil_divide divisor
      self % divisor > 0 ? ( self / divisor ) + 1 : self / divisor
    end

    def bits
      bits_per_byte = 8
      self.ceil_divide bits_per_byte
    end

    def kibibytes
      self * 1024
    end
    alias_method :kibibyte, :kibibytes
    alias_method :KiB,      :kibibytes

    def mebibytes
      self.kibibytes * 1024
    end
    alias_method :mebibyte, :mebibytes
    alias_method :MiB,      :mebibytes

    def gibibytes
      self.mebibytes * 1024
    end
    alias_method :gibibyte, :gibibytes
    alias_method :GiB,      :gibibytes

    def tebibytes
      self.gibibytes * 1024
    end
    alias_method :tebibyte, :tebibytes
    alias_method :TiB,      :tebibytes

    def pebibytes
      self.tebibytes * 1024
    end
    alias_method :pebibyte, :pebibytes
    alias_method :PiB,      :pebibytes

    def exbibytes
      self.pebibytes * 1024
    end
    alias_method :exbibyte, :exbibytes
    alias_method :EiB,      :exbibytes

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
