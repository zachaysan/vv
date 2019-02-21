require_relative "test_helper.rb"

class ReadlineMethodsTest < Minitest::Test

  def test_readline_included_vv
    assert Readline::vv_enabled?
  end

  def test_readline_prompt_takes_only_string
    message = assert_raises(ArgumentError) {
      Readline.prompt nil
    }.message

    expected_message = "Expected `String` instance, not `NilClass`."
    assert_equal expected_message, message
  end

end
