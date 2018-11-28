module VV
  module NilMethods

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def vv_included?
        true
      end

    end

    def to_boolean
      false
    end

  end

end
