module VV

  module RandomClassSettings

    def random_identifier_default_length
      40
    end

  end

  module RandomMethods

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def vv_included?
        true
      end

      def default_charset
        36
      end

      def identifier length=nil, charset_radix: nil
        length ||= self.random_identifier_default_length

        charset_radix ||= self.default_charset
        largest_digit   = (charset_radix - 1).to_s charset_radix

        start  = ( largest_digit * ( length - 1 ) ).to_i charset_radix
        start += 1

        finish = ( largest_digit * ( length     ) ).to_i charset_radix
        range  = start..finish

        SecureRandom.random_number(range).to_s charset_radix
      end

      def character *args, capitals: false
        String.letters_and_numbers(capitals: capitals)
          .sample(*args, random: SecureRandom)
      end

    end

  end
end
