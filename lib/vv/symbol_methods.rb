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

    def vv_json
      self.to_s.vv_json
    end

    def insta
      self.to_s.insta
    end

    def insta_sym
      self.to_s.insta_sym
    end

    def setter
      self.to_s.setter
    end

    def setter_sym
      self.to_s.setter_sym
    end

    def plural? *args, **kwargs
      self.to_s.plural?( *args, **kwargs )
    end

    def singular? *args, **kwargs
      self.to_s.singular?( *args, **kwargs )
    end

  end
end
