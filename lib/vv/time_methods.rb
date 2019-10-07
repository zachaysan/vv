module VV
  module TimeMethods

    def self.included(base)
      base.instance_eval do
        extend(ClassMethods)
        alias_method :second, :sec
        alias_method :sub_second, :subsec
      end
    end

    module ClassMethods

      def vv_included?
        true
      end

    end

  end
end
