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

end
