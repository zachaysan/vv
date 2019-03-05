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

      def letters_and_numbers capitals: false
        response  = self.letters
        response += self.capitals if capitals
        response += self.numbers
      end

      def capture_stdout(&block)
        original_stdout = $stdout
        $stdout = StringIO.new
        yield
        $stdout.string
      ensure
        $stdout = original_stdout
      end
      alias_method :get_stdout, :capture_stdout

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

      def equals_sign
        "="
      end

      def comma
        ","
      end

      def period
        "."
      end

      def colon
        ":"
      end

      def underscore_character
        "_"
      end

      def space
        " "
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

    # Instance methods start

    def includes? *args
      self.include?(*args)
    end

    def starts_with? *args
      self.start_with?(*args)
    end

    def ends_with? *args
      self.end_with?(*args)
    end

    def shift
      self.slice!(0)
    end
    alias_method :shift!, :shift

    def pop
      self.slice!(-1)
    end
    alias_method :pop!, :pop

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

    def with_newline
      self.with_ending newline
    end

    def split_via *arguments, ignore_newlines: false
      newlines_encountered = self.include? String.newline
      newlines_ok   = ( not newlines_encountered )
      newlines_ok ||= ignore_newlines

      message  = "Newlines encountered, but disallowed. "
      message += \
      "Set `ignore_newlines` to true to treat as spaces."

      fail message unless newlines_ok

      args = arguments.flatten.sort_by(&:length).reverse

      response = [self.gsub(String.newline, String.space)]

      args.map do |arg|

        response.map! do |fragment|
          fragment.split arg
        end

        response.flatten!
      end

      response
    end

    def split_english ignore_newlines: false

      options = [ ", ",
                  ", and ",
                  ", or ",
                  " and ",
                  " or "]
      self.split_via(options,
                     ignore_newlines: ignore_newlines)
        .map(&:strip)
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

    def safe_filename?( allow_hidden: false )
      unsafe   = self.blank?

      unsafe ||= self.starts_with?(period) unless allow_hidden
      unsafe ||= self.starts_with? dash

      unsafe ||= self.end_with? period
      unsafe ||= self.end_with? dash

      unsafe ||= self =~ self.safe_filename_characters.to_regex_filter

      ! unsafe
    end

    def safe_path?( allow_hidden: false, allow_absolute: false )
      safe = self.safe_dir_path? allow_hidden: allow_hidden,
                                 allow_absolute: allow_absolute

      unsafe   = ( ! safe )
      unsafe ||= self.ends_with? File::SEPARATOR

      ! unsafe
    end

    def safe_dir_path? allow_hidden: false,
                       allow_absolute: true
      separator = File::SEPARATOR

      unsafe   = false
      unsafe ||= self.starts_with?(separator) unless allow_absolute
      unsafe ||= self.after(separator, safe: false)
                   .split(separator).map do |fragment|
        fragment.safe_filename? allow_hidden: allow_hidden
      end.map(&:!).any?

      ! unsafe
    end

    def is_directory_path?
      File.directory? self
    end

    def is_file_path?
      File.file? self
    end

    def file_join *args
      unsafe = args.reject(&:safe_path?)

      return File.join self, *args if unsafe.blank?

      frags = unsafe.first(3).stringify_collection grave: true
      count = unsafe.count

      message = \
      "#{count} unsafe path fragments including: #{frags}"

      fail ArgumentError, message
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

    def parse notation: :json
      message = "Only JSON support at this time."
      fail NotImplementedError, message unless notation == :json

      JSON.parse self
    end

    def parse_json
      self.parse notation: :json
    end

    def to_h parse: :json, symbolize_keys: false
      message = "Only JSON support at this time."
      fail NotImplementedError, message unless parse == :json

      response = self.parse_json

      response.symbolize_keys! if symbolize_keys

      return response if response.to_h == response

      message = \
      "Parse string was #{response.class}, instead of Hash."
      fail message
    end

    def to_i!
      Integer(self)
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

    def unstyle
      self.gsub( /\e\[+\d+m/, empty_string )
        .gsub( /\e\[((\d+)+\;)+\d+m/, empty_string )
    end
    alias_method :unstyled, :unstyle

    def unstyle!
      self.gsub!( /\e\[+\d+m/,          empty_string )
      self.gsub!( /\e\[((\d+)+\;)+\dm/, empty_string )
    end

    def style *args
      color = bold = underline = italic = nil

      args.flatten!
      args.map! { |arg| arg.to_sym }

      args.each do |arg|
        if Color.known_color? arg
          if color.present?
            raise "Color already set"
          else
            color = Color.new arg
          end
        elsif arg == :bold
          bold = Bold.new
        elsif arg == :underline
          underline = Underline.new
        elsif ( arg == :italic ) or ( arg == :italics )
          italic = Italic.new
        else
          raise NotImplemented
        end
      end

      reset = Format.reset_code
      response = self.chomp(reset) + reset

      response.prepend italic.code    if italic
      response.prepend underline.code if underline
      response.prepend bold.code      if bold

      if color
        start  = response.index color.start_code
        if start
          finish = response[start..-1].index("m") + start
          response.slice! start..finish
        end
        response.prepend color.code
      end

      response
    end

    def insta
      return self if self.starts_with?("@")
      "@#{self}"
    end

    def insta_sym
      self.insta.to_sym
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

    def cli_puts **kwargs
      puts String.get_stdout { self.cli_print( **kwargs ) }
    end

    def cli_print width: 80,
                  padding: 0,
                  position: 0,
                  hard_wrap: false

      raise NotImplemented if hard_wrap
      raise NotImplemented if self.includes? newline

      pad_length = padding - position
      position += pad_length
      print pad_length.spaces

      unstyled_length = self.unstyled.length
      remaining_length = width - position
      if unstyled_length <= remaining_length
        print self
        position += unstyled_length
        return position
      end

      space_index   = self[0..remaining_length].rindex(" ")
      space_index ||= self.index(" ")

      if space_index
        sub = self[0..space_index]
        print sub
        puts
        position = 0
        start = space_index + 1
        return self[start..-1].cli_print width: width,
                                         padding: padding,
                                         position: position,
                                         hard_wrap: hard_wrap
      else
        print self
        puts
        position = 0
      end

      return position
    end

  end
end
