module VV
  module FloatMethods

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def vv_included?
        true
      end

    end

    def vv_json nan_coerces: false,
                infinity_coerces: false,
                max: nil,
                min: nil

      fail "Expecting numeric value for `max`" if max.is_a? String
      fail "Expecting numeric value for `min`" if min.is_a? String

      message = \
      "Infinite not convertable sans `infinity_coerces: true`. "
      message += "Set `max` and `min` for non-null coercion."
      fail message if infinite? unless infinity_coerces

      message = \
      "NaN not convertable sans `nan_coerces: true`."
      fail message if self.nan? unless nan_coerces

      return nil.to_json if nan?

      use_max   = ( max.present? and self > max )
      use_max ||= ( infinite?    and self > 0 )
      return max.to_json if use_max

      use_min   = ( min.present? and self < min )
      use_min ||= ( infinite?    and self < 0 )
      return min.to_json if use_min

      JSON.dump(self)
    end

  end
end
