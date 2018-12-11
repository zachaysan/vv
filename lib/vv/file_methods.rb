module VV
  module FileMethods

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def vv_included?
        true
      end

      def vv_readlines *args, **kwargs
        File.readlines(*args, **kwargs).map!(&:chomp)
      end

    end

    def vv_readlines
      self.class.vv_readlines self
    end

  end
end
