module VV
  module StringMethods

    def self.included(base)
      base.extend(ClassMethods)
      base.extend(SharedInstanceAndClassMethods)
      base.include(SharedInstanceAndClassMethods)
    end

    module ClassMethods

      def vv_included?
        true
      end

      def letters
        ("a".."z").to_a
      end

      def numbers
        ("0".."9").to_a
      end

      def capitals
        ("A".."Z").to_a
      end

      def letters_and_numbers(capitals: false)
        response  = self.letters
        response += self.capitals if capitals
        response += self.numbers
      end

    end

    module SharedInstanceAndClassMethods

      def empty_string
        ""
      end

      def forward_slash
        "/"
      end

      def dash
        "-"
      end

      def period
        "."
      end

      def underscore_character
        "_"
      end

      def newline
        "\n"
      end

      # See: `safe_filename?` and `safe_path?` methods
      def safe_filename_characters
        numbers    = '0-9'
        lowercase  = 'a-z'
        uppercase  = 'A-Z'

        [ dash,
          numbers,
          lowercase,
          uppercase,
          underscore_character,
          period ].join
      end

    end

    def blank?
      self == ""
    end

    def starts_with? *args
      self.start_with?(*args)
    end

    def ends_with? *args
      self.end_with?(*args)
    end

    def after(string, safe: true)
      if safe && ! self.starts_with?(string)
        message = "String does not start with #{string}"
        raise RuntimeError, message
      elsif not self.starts_with?(string)
        return self
      end

      self[string.size..-1]
    end

    def with_ending(string)
      self.chomp(string) + string
    end

    def squish!
      self.gsub!(/\A[[:space:]]+/, "")
      self.gsub!(/[[:space:]]+\z/, "")
      self.gsub!(/[[:space:]]+/, " ")
      self
    end

    def squish
      self.dup.squish!
    end

    def format!(other)
      mappings = {}
      self.split('#{')[1..-1].map do | token_fragment |
        format_string = token_fragment.split("}").first
        token = format_string.squish

        value = other.instance_variable_get(token).to_s
        wrapped_format_string = '#{' + format_string + "}"
        mappings[wrapped_format_string] = value
      end

      response = self.dup

      mappings.each do |key, value|
        response.gsub! key, value
      end

      response
    end

    def matches_glob pattern
      File.fnmatch(pattern, self)
    end

    def to_regex
      Regexp.new self
    end

    def to_regex_filter
      regex_string = '[^' + self + ']'
      regex_string.to_regex
    end

    def to_regexp_filter
      self.to_regex_filter
    end

    def safe_filename?
      unsafe   = self.blank?
      unsafe ||= self.starts_with? period
      unsafe ||= self.starts_with? dash

      unsafe ||= self.end_with? period
      unsafe ||= self.end_with? dash

      unsafe ||= self =~ self.safe_filename_characters.to_regex_filter

      ! unsafe
    end

    def safe_path?
      separator = File::SEPARATOR

      unsafe   = self.starts_with? separator
      unsafe ||= self.ends_with?   separator
      unsafe ||= self.split(separator).map(&:safe_filename?).map(&:!).any?

      ! unsafe
    end

    def hex?
      return false if self.blank?
      match_non_hex_digits = /\H/
      !self[match_non_hex_digits]
    end

    def number?
      return false if self.blank?
      self.gsub(/[^0-9]/, '') == self
    end

    def readable_number?
      self.readable_to_i
      true
    rescue StandardError => e
      return false if e.message == "String is not a number"
      raise
    end

    def to_boolean
      _true = self == "true"
      return true if _true

      _false = self == "false"
      return false if _false

      message = %w[ Unable to cast supplied string to boolean,
                    only `"true"` and `"false"` can be coerced into
                    boolean. ].spaced
      raise RuntimeError, message
    end

    def readable_to_i
      return self.to_i if self.number?

      valid_postfix = self._numeral_postfixes.include? self.last
      valid_body    = self[0...-1].number?
      valid = valid_body && valid_postfix

      message = "String is not a number"
      raise StandardError, message unless valid

      self[0...-1].to_i * self._numeral_postfixes[self.last]
    end

    def _numeral_postfixes
      { k: 1000,
        m: 1000_000,
        b: 1000_000_000,
        t: 1000_000_000_000 }.stringify_keys
    end

    def insta
      return self if self.starts_with?("@")
      "@#{self}"
    end

    def to position
      self[0..position]
    end

    def from position
      self[position..-1]
    end

    def _ensure_pluralize_available!
      message = "String does not define pluralize."
      pluralize_available = self.respond_to? :pluralize
      raise NotImplementedError, message unless pluralize_available
    end

    def _ensure_singularize_available!
      message = "String does not define singularize."
      singularize_available = self.respond_to? :singularize
      raise NotImplementedError, message unless singularize_available
    end

    def plural?(coward: true)
      self._ensure_pluralize_available!
      self._ensure_singularize_available!

      plural = self == self.pluralize
      return plural if !coward || !plural

      non_ambiguous = self.pluralize != self.singularize

      message = \
      "String is ambiguously plural. Cowardly exiting."
      raise RuntimeError, message unless non_ambiguous

      true
    end

    def singular?(coward: true)
      self._ensure_pluralize_available!
      self._ensure_singularize_available!

      singular = self == self.singularize
      return singular if !coward || !singular

      non_ambiguous = self.pluralize != self.singularize

      message = \
      "String is ambiguously singular. Cowardly exiting."
      raise RuntimeError, message unless non_ambiguous

      true
    end

    def last(limit = 1)
      if limit == 0
        ""
      elsif limit >= size
        self.dup
      else
        self.from(-limit)
      end
    end

    def first limit=1
      if limit == 0
        ""
      elsif limit >= size
        dup
      else
        to(limit - 1)
      end
    end

    def second
      self[1]
    end

    def third
      self[2]
    end

    def fourth
      self[3]
    end

    def fifth
      self[4]
    end

    def sixth
      self[5]
    end

    def seventh
      self[6]
    end

    def eighth
      self[7]
    end

    def ninth
      self[8]
    end

    def tenth
      self[9]
    end

  end
end
