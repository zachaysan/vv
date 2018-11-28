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

  end
end
