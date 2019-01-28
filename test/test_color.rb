require "minitest/autorun"
require "vv"

class ColorTest < Minitest::Test

  def test_rgb_from_name
    color = Color.new :forestgreen
    expected_green = 139
    expected_blue  = expected_red = 34

    assert_equal expected_red,   color.red
    assert_equal expected_green, color.green
    assert_equal expected_blue,  color.blue

    expected_rgb = [ expected_red,
                     expected_green,
                     expected_blue ]
    assert_equal expected_rgb, color.rgb
  end

  def test_hex_from_name
    color = Color.new :forestgreen
    expected_hex = "#228b22"

    assert_equal expected_hex, color.hex
    assert_equal expected_hex, color.html
  end

end
