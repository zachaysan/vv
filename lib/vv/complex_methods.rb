module VV
  module ComplexMethods

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def vv_included?
        true
      end

    end

    def to_d
      self.non_imaginary!
      self.real.to_f.to_d
    end

    def real_digits unsafe: false
      self.non_imaginary! unless unsafe
      self.real.to_d.to_digits
    end

    def non_imaginary!
      message = "Complex number contains imaginary part."
      fail message if imaginary?
    end

  end
end
