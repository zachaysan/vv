module VV
  module HashMethods

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def vv_included?
        true
      end

    end

    def vv_json
      VV::JSON.generate self
    end

    def symbolize_keys
      transform_keys{ |key| key.to_sym }
    end

    def symbolize_keys!
      transform_keys!{ |key| key.to_sym }
    end

    def stringify_keys
      transform_keys{ |key| key.to_s }
    end

    def stringify_keys!
      transform_keys!{ |key| key.to_s }
    end

    def transform_keys
      return enum_for(:transform_keys) unless block_given?
      result = self.class.new
      self.each_key do |key|
        result[yield(key)] = self[key]
      end
      result
    end

    def transform_keys!
      return self.enum_for(:transform_keys!) unless block_given?
      self.keys.each do |key|
        self[yield(key)] = self.delete(key)
      end
      self
    end

    def cli_print width: nil,
                  position: nil,
                  padding: nil

      width    ||= 80
      position ||= 0
      padding  ||= 0

      key_padding = nil

      String.capture_stdout {
        key_padding = self.keys.map { | key |
          key.cli_print width: width,
                        position: position,
                        padding: padding
        }.max
      }

      key_padding += 1

      self.each do | key, value |
        position = key.cli_print width: width,
                                 position: position,
                                 padding: padding

        print ( key_padding - position ).spaces

        value_padding = position = key_padding

        position = value.cli_print width: width,
                                   position: position,
                                   padding: value_padding

        puts
        position = 0
      end

      position
    end

  end
end
