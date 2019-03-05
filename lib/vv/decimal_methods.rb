module VV
  module DecimalMethods

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def vv_included?
        true
      end

    end

    def vv_json **kwargs
      self.to_digits
    end

  end
end
