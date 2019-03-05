module VV
  module NumericMethods

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def vv_included?
        true
      end

    end

    def imaginary?
      ! ( self.imaginary == 0 )
    end

    def real_digits
      return real.to_digits if real.respond_to? :to_digits
      real.to_s
    end

    def readable_number precision: 3, significant: false
      message = "Cannot make imaginary number readable"
      fail message if imaginary?

      _int_digits,
      _remaining_digits = self.real_digits.split String.period

      _int_digits = \
      _int_digits.after String.dash, safe: false

      if _int_digits.size > 4
        # TODO: This type of pattern comes up all the time with
        #       strings. Figure out a way of abstracting it.
        offset   = ( _int_digits.size ) % 3
        required = ( _int_digits.size - 1 ) / 3

        index = required * 3 + ( offset % -3 )
        while index > 0
          _int_digits.insert(index, String.comma)
          index -= 3
        end
      end

      response = \
      real.negative? ? String.dash : String.empty_string

      response += _int_digits
      return response unless _remaining_digits
      response += String.period

      last_digit = significant ? -1 : ( precision )
      if significant || precision >= _remaining_digits.size
        dec_portion = _remaining_digits
      else
        dec_portion = \
        ( _remaining_digits[0..last_digit].to_f / 10 )
        .round.to_s
      end

      response + dec_portion
    end
    alias_method :readable, :readable_number

  end
end
