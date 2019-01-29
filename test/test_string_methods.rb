# coding: utf-8
require_relative "test_helper.rb"

class StringMethodsTest < Minitest::Test

  def test_letters
    assert_equal ("a".."z").to_a, String.letters
    expected_length = 26
    assert_equal expected_length, String.letters.length
  end

  def test_numbers
    assert_equal ("0".."9").to_a, String.numbers
    expected_length = 10
    assert_equal expected_length, String.numbers.length
  end

  def test_capitals
    assert_equal ("A".."Z").to_a, String.capitals
    expected_length = 26
    assert_equal expected_length, String.capitals.length
  end

  def test_letters_and_numbers
    expected_length = 36
    assert_equal expected_length, String.letters_and_numbers.length

    expected_length += 26
    assert_equal expected_length,
                 String.letters_and_numbers(capitals: true).length
  end

  def test_empty_string_classmethod
    expected_empty_string = ""
    assert_equal String.empty_string, expected_empty_string
  end

  def test_empty_string
    expected_empty_string = ""
    assert_equal "Example".empty_string, expected_empty_string
  end

  def test_forward_slash_classmethod
    expected_forward_slash = "/"
    assert_equal String.forward_slash, expected_forward_slash
  end

  def test_forward_slash
    expected_forward_slash = "/"
    assert_equal "Example".forward_slash, expected_forward_slash
  end

  def test_dash_classmethod
    expected_dash = "-"
    assert_equal String.dash, expected_dash
  end

  def test_dash
    expected_dash = "-"
    assert_equal "Example".dash, expected_dash
  end

  def test_period_classmethod
    expected_period = "."
    assert_equal String.period, expected_period
  end

  def test_period
    expected_period = "."
    assert_equal "Example".period, expected_period
  end

  def test_underscore_character_classmethod
    expected_underscore_character = "_"
    assert_equal String.underscore_character,
                 expected_underscore_character
  end

  def test_underscore_character
    expected_underscore_character = "_"
    assert_equal "Example".underscore_character,
                 expected_underscore_character
  end

  def test_newline_classmethod
    expected_newline = "\n"
    assert_equal String.newline, expected_newline
  end

  def test_newline
    expected_newline = "\n"
    assert_equal "Example".newline, expected_newline
  end

  def test_safe_filename_characters_classmethod
    expected_string = '-0-9a-zA-Z_.'
    assert_equal expected_string, String.safe_filename_characters
  end

  def test_safe_filename_characters
    expected_string = '-0-9a-zA-Z_.'
    assert_equal expected_string, "safe".safe_filename_characters
  end

  def test_blank?
    assert "".blank?
    refute "Face".blank?
  end

  def test_starts_with?
    assert "Red fish".starts_with? "Red"
    refute "Red fish".starts_with? "Blue"
  end

  def test_ends_with?
    assert "Racecar".ends_with? "car"
    refute "Racecar".ends_with? "Fiery crash"
  end

  def test_after
    expected_string = "Bond"
    assert_equal expected_string, "Mr. Bond".after("Mr. ")
    assert_equal expected_string, "Bond".after("Mr. ", safe: false)
    expected_message = "String does not start with Mr. "
    message = assert_raises(RuntimeError) { "Bond".after("Mr. ") }
    assert_equal expected_message, message.to_s
  end

  def test_with_ending
    expected_string = "lol.rb"
    assert_equal expected_string, "lol"   .with_ending(".rb")
    assert_equal expected_string, "lol.rb".with_ending(".rb")
  end

  def test_squish!
    expected_string = "pulpy fruit paste"
    squishy_string = "\npulpy\t fruit   paste  "
    squishy_string.squish!
    assert_equal expected_string, squishy_string
  end

  def test_squish
    expected_string = "pulpy fruit paste"
    squishy_string = "\npulpy\t fruit   paste  "
    assert_equal expected_string, squishy_string.squish
  end

  def test_format!
    template = 'Age: #{@age}, Rank: #{@rank}'
    @age = 33
    @rank = "Spec Ops Int Sergeant"
    expected_string = "Age: 33, Rank: Spec Ops Int Sergeant"
    assert_equal expected_string, template.format!(self)
  end

  def test_matches_glob
    assert "Canada".matches_glob "Can*"
    assert "Canada".matches_glob "Can*da"
    assert "Canada".matches_glob "Can*ada"
    assert "Canada".matches_glob "Ca?a?a"
    refute "Canada".matches_glob "Ameri*"
    refute "Canada".matches_glob "Ameri*"
    refute "Canada".matches_glob "Can*du"
  end

  def test_to_regex
    string = "[^0-9]"
    expected_regex = Regexp.new('[^0-9]')
    assert_equal expected_regex, string.to_regex
  end

  def test_to_regex_filter
    string = "a-c"
    expected_regexp = Regexp.new('[^a-c]')
    assert_equal expected_regexp, string.to_regex_filter

    unsafe = "caca" =~ string.to_regex_filter
    refute unsafe

    unsafe = "xxxx" =~ string.to_regex_filter
    assert unsafe

    unsafe = "caxx" =~ string.to_regex_filter
    assert unsafe
  end

  def test_safe_filename?
    safe_filenames = %w[ safe.txt
                         safeysafe
                         saf-eysafe.json.gzip
                         safe.....safe.tar ]

    safe_filenames.each { |filename| assert filename.safe_filename? }

    unsafe_filenames = %w[ unsafe-
                           -safeun
                           .unsafee
                           unsaf;ff..eee.
                           un/safe/ee
                           un/../safe
                           unяusskie ]

    unsafe_filenames.map do |filename|
      refute filename.safe_filename?
    end

    null_char = "\u0000"
    unsafe_filename = "something#{null_char}"
    refute unsafe_filename.safe_filename?
  end

  def test_safe_path?
    safe_paths = %w[ safe/safe.txt
                     safeysafe
                     saf-eysa/f/e.json.gzip
                     farcity/safe.....safe.tar ]

    safe_paths.each { |path| assert path.safe_path? }

    unsafe_paths = %w[ /safe/safe.txt
                       safeysafe/
                       saf-eysa//e.json.gzip
                       farcity/s/a/fe/.....safe.tar
                       ../lol
                       lol/../../foo ]

    unsafe_paths.each { |path| refute path.safe_path? }
  end

  def test_hex?
    assert "00001AB".hex?
    assert "1322fe2".hex?
    assert "feedBEE".hex?
    assert "1344955".hex?
    assert "0".hex?

    refute "245949G".hex?
    refute "".hex?
    refute " ".hex?
    refute "\u0000".hex?
    refute "\n".hex?
  end

  def test_number?
    assert "345".number?
    assert "007".number?
    assert "0".number?

    refute "3A3".number?
    refute "".number?
    refute " ".number?
    refute "\n".number?
  end

  def test_readable_number?
    assert "04".readable_number?
    assert "4".readable_number?
    assert "4t".readable_number?
    assert "33k".readable_number?

    refute "t53".readable_number?
    refute "".readable_number?
  end

  def test_to_i!
    expected_int1 = 4
    expected_int2 = 0
    expected_int3 = -22
    expected_int4 = 1_000_000_000

    assert_equal expected_int1, "4".to_i!

    assert_equal expected_int2, "00".to_i!
    assert_equal expected_int2, "0".to_i!
    assert_equal expected_int2, "-0".to_i!

    assert_equal expected_int3, "-22".to_i!
    assert_equal expected_int4, "1000000000".to_i!

    message = assert_raises(ArgumentError) { "ab".to_i! }
    expected_message = "invalid value for Integer(): \"ab\""
    assert_equal expected_message, message.to_s
  end

  def test_to_boolean
    assert "true".to_boolean.is_a? TrueClass
    assert "true".to_boolean
    assert "false".to_boolean.is_a? FalseClass
    refute "false".to_boolean
    expected_message = \
    'Unable to cast supplied string to boolean, only `"true"` ' \
    'and `"false"` can be coerced into boolean.'
    message = assert_raises(RuntimeError) { "t".to_boolean }.message
    assert_equal expected_message, message
  end

  def test_readable_to_i
    expected_value = 2000
    assert_equal expected_value, "2k".readable_to_i

    expected_value = 4000_000
    assert_equal expected_value, "4m".readable_to_i

    expected_value = 5 * 1000 ** 3
    assert_equal expected_value, "5b".readable_to_i

    expected_value = 95 * 1000 ** 4
    assert_equal expected_value, "95t".readable_to_i

    %w[ m567 5m66 t ].each do |non_readable_number|
      message = assert_raises(StandardError) do
        non_readable_number.readable_to_i
      end.message
      expected_message = "String is not a number"
      assert_equal expected_message, message
    end
  end

  def test_style
    foo_blue = "foo".style :blue
    expected_encoding = "\e[38;2;0;0;255mfoo\e[0m"
    assert_equal expected_encoding, foo_blue
  end

  def test_style_with_bold
    expected_encoding = "\e[38;2;34;139;34m\e[1mBAR\e[0m"

    bold_forest_green_bar = "BAR".style :forestgreen, :bold
    assert_equal expected_encoding, bold_forest_green_bar

    bold_forest_green_bar = "BAR".style :forest_green, :bold
    assert_equal expected_encoding, bold_forest_green_bar
  end

  def test_style_with_underline
    underlined_elf = "elf".style :underline
    expected_elf_on_a_shelf = "\e[4melf\e[0m"

    assert_equal expected_elf_on_a_shelf, underlined_elf
  end

  def test_style_with_italic
    sarcasm = "of course not".style :italic
    expected_sarcasm = "\e[3mof course not\e[0m"
    assert_equal expected_sarcasm, sarcasm
    # Some people use the plural when styling
    sarcasm = "of course not".style :italics
    assert_equal expected_sarcasm, sarcasm
  end

  def test_chained_styles
    sarcasm = "of course not".style :italic
    chained = sarcasm.style(:blue)
                .style :forestgreen, :bold, :underline
    expected_chained = \
    "\e[38;2;34;139;34m\e[1m\e[4m\e[3mof course not\e[0m"
    assert_equal expected_chained, chained
  end

  def test_insta
    assert_equal "@age", "age".insta
    assert_equal "@age", "@age".insta
  end

  def test_to
    assert_equal "ban", "bananas".to(2)
    assert_equal "bananas", "bananas".to(200)
    assert_equal "b", "bananas".to(0)
  end

  def test_from
    assert_equal "nanas", "bananas".from(2)
    assert_equal "bananas", "bananas".from(0)

    assert_nil "bananas".from(200)
  end

  def test_plural?
    banana  = "banana"
    bananas = "bananas"

    def banana.singularize
      "banana"
    end

    def banana.pluralize
      "bananas"
    end

    def bananas.singularize
      "banana"
    end

    def bananas.pluralize
      "bananas"
    end

    assert bananas.plural?
    refute banana.plural?

    sheep = "sheep"

    def sheep.pluralize
      "sheep"
    end

    def sheep.singularize
      "sheep"
    end

    message = assert_raises(RuntimeError) { sheep.plural? }.message
    expected_message = "String is ambiguously plural. Cowardly exiting."
    assert_equal expected_message, message

    assert sheep.plural?( coward: false )

    ruby = "ruby"
    message = assert_raises(NotImplementedError) { ruby.plural? }.message
    expected_message = "String does not define pluralize."
    assert_equal expected_message, message

    def ruby.pluralize
      "rubies"
    end

    message = assert_raises(NotImplementedError) { ruby.plural? }.message
    expected_message = "String does not define singularize."
    assert_equal expected_message, message
  end

  def test_singular?
    banana  = "banana"
    bananas = "bananas"

    def banana.singularize
      "banana"
    end

    def banana.pluralize
      "bananas"
    end

    def bananas.singularize
      "banana"
    end

    def bananas.pluralize
      "bananas"
    end

    refute bananas.singular?
    assert banana.singular?

    sheep = "sheep"

    def sheep.pluralize
      "sheep"
    end

    def sheep.singularize
      "sheep"
    end

    message = assert_raises(RuntimeError) { sheep.singular? }.message
    expected_message = "String is ambiguously singular. Cowardly exiting."
    assert_equal expected_message, message

    assert sheep.singular?( coward: false )

    ruby = "ruby"
    message = \
    assert_raises(NotImplementedError) { ruby.singular? }.message
    expected_message = "String does not define pluralize."
    assert_equal expected_message, message

    def ruby.pluralize
      "rubies"
    end

    message = \
    assert_raises(NotImplementedError) { ruby.singular? }.message
    expected_message = "String does not define singularize."
    assert_equal expected_message, message
  end

  def test_last
    expected_character = "e"
    assert_equal expected_character, "nevermore".last

    expected_string = "more"
    assert_equal expected_string, "more".last(4)
  end

  def test_first
    assert_equal "1", "123456789A".first
    assert_equal "123", "123456789A".first(3)
    assert_equal "123456789A", "123456789A".first(300)
  end

  def test_second
    assert_equal "2", "123456789A".second
  end

  def test_third
    assert_equal "3", "123456789A".third
  end

  def test_fourth
    assert_equal "4", "123456789A".fourth
  end

  def test_fifth
    assert_equal "5", "123456789A".fifth
  end

  def test_sixth
    assert_equal "6", "123456789A".sixth
  end

  def test_seventh
    assert_equal "7", "123456789A".seventh
  end

  def test_eighth
    assert_equal "8", "123456789A".eighth
  end

  def test_ninth
    assert_equal "9", "123456789A".ninth
  end

  def test_tenth
    assert_equal "A", "123456789A".tenth
  end

end
