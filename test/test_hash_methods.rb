require_relative "test_helper.rb"

class HashMethodsTest < Minitest::Test

  def test_includes
    hash = { foo: true }
    assert hash.includes?(:foo)
  end

  def test_cli_print
    simple = { "Title"  => "US Sec Def",
               "Serial" => "0569548345" }

    expected_string = "Title  US Sec Def\n" + \
                      "Serial 0569548345\n"

    printed = String.capture_stdout { simple.cli_print }

    assert_equal expected_string, printed
  end

  def test_cli_print_with_array
    git_stuff = [ "something wicked", "comes this way" ]
    document = { "usage git:" => git_stuff }

    printed = String.capture_stdout { document.cli_print }
    expected_string = \
    "usage git: something wicked comes this way"

    assert_equal expected_string.with_newline, printed
    git_stuff.cli_print_separator = " | "
    printed = String.capture_stdout { document.cli_print }

    expected_string = \
    "usage git: something wicked | comes this way"

    assert_equal expected_string.with_newline, printed

    width = "usage git: something wicked ".length
    printed = String.capture_stdout {
      document.cli_print width: width
    }
    expected_string = \
    "usage git: something wicked\n" + \
    "           comes this way"

    assert_equal expected_string.with_newline, printed

    width = "usage git: something wicked |".length
    printed = String.capture_stdout {
      document.cli_print width: width
    }

    assert_equal expected_string.with_newline, printed

    width = "usage git: something wicked | c".length
    printed = String.capture_stdout {
      document.cli_print width: width
    }

    assert_equal expected_string.with_newline, printed

    expected_string = \
    "usage git: something wicked | comes this way"

    width = expected_string.length
    printed = String.capture_stdout {
      document.cli_print width: width
    }
    assert_equal expected_string.with_newline, printed
  end

  def test_cli_print_with_color
    wicked = "wicked".style :indianred, :bold
    git_stuff = [ "something #{wicked}", "comes this way" ]
    document = { "usage git:" => git_stuff }
    printed = String.capture_stdout {
      document.cli_print
    }
    expected_string = \
    "usage git: something wicked comes this way"

    width = expected_string.length

    position = nil
    printed = String.capture_stdout {
      position = document.cli_print width: width
    }

    expected_position = 0
    assert_equal expected_position, position
    assert_equal width, printed.unstyled.chomp(String.newline).length

    expected_string  = "usage git: something "
    expected_string += "\e[38;2;205;92;92m\e[1mwicked\e[0m "
    expected_string += "comes this way"

    assert_equal expected_string.with_newline, printed
  end

  def test_stringify_keys
    hash = { hero: :batman }
    expected_hash = { "hero" => :batman }
    refute_equal hash, hash.stringify_keys
    refute_equal expected_hash, hash
    assert_equal expected_hash, hash.stringify_keys
    hash.stringify_keys!
    assert_equal expected_hash, hash
  end

  def test_symbolize_keys
    hash = { "hero" => "batman" }
    expected_hash = { hero: "batman" }
    refute_equal hash, hash.symbolize_keys
    refute_equal expected_hash, hash
    assert_equal expected_hash, hash.symbolize_keys
    hash.symbolize_keys!
    assert_equal expected_hash, hash
  end

end
