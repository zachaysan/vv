module VV
  module SymbolMethods

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def vv_included?
        true
      end
    end

    def insta
      self.to_s.insta
    end

    def insta_sym
      self.to_s.insta_sym
    end

    def plural? *args, **kwargs
      self.to_s.plural?( *args, **kwargs )
    end

    def singular? *args, **kwargs
      self.to_s.singular?( *args, **kwargs )
    end

  end
end
