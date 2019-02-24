module VV
  module ArrayMethods

    def self.included(base)
      base.extend(ClassMethods)
      base.include(VV::SetMethods::SetAndArrayMethods)
      base.attr_accessor :cli_print_separator
    end

    module ClassMethods

      def vv_included?
        true
      end

    end

    def to_json
      JSON.dump self
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

    def cli_print width: 80,
                  padding: 0,
                  position: 0,
                  separator: nil

      @cli_print_separator ||= String.space
      separator ||= @cli_print_separator

      pad_length = padding - position
      position += pad_length
      print pad_length.spaces

      separator_required = false
      self.each do | elem |
        printable = String.capture_stdout {
          elem.cli_print width: width,
                         padding: padding,
                         position: position
        }
        string = printable.dup
        string.prepend separator if separator_required
        delta = string.unstyled.length

        if position + delta > width
          puts
          print padding.spaces
          print printable
          position = padding + printable.unstyled.length
        else
          print string
          position += delta
        end
        separator_required = true
      end
      position
    end

  end

end
