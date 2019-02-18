require_relative "test_helper.rb"

class IntegerMethodsTest < Minitest::Test

  def test_spaces
    space_count = 3
    expected_spaces = "   "
    assert_equal space_count, expected_spaces.size
    assert_equal expected_spaces, space_count.spaces
  end

  def test_to_i!
    four = 4
    assert_equal four, four.to_i!
  end

  def test_dashes
    assert_equal "-", 1.dashes
    assert_equal "---", 3.dashes
    assert_equal "", 0.dashes
    assert_equal "", -0.dashes
    assert_equal "", -4.dashes
  end

  def test_characters
    assert_equal "@@@", 3.characters("@")
    message = assert_raises(RuntimeError) {
      -3.characters( "@", fail_on_negative: true )
    }.message
    expected_message = "Expected non-negative integer, not `-3`."
    assert_equal expected_message, message
  end

end
