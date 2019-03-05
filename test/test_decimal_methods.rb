require_relative "test_helper.rb"

class DecimalMethodsTest < Minitest::Test

  def test_load
    assert BigDecimal.vv_included?
  end

  def test_vv_json
    simple_decimal = "0.5".to_d
    expected_json  = "0.5"
    refute_equal expected_json, simple_decimal
    assert_equal expected_json, simple_decimal.vv_json
  end

  def test_readable_number
    number = "0.555555555555".to_d
    expected_readable = "0.556"
    assert_equal expected_readable, number.readable
    number = "0.555".to_d
    expected_readable = "0.555"
    assert_equal expected_readable, number.readable
    number = "-0.555".to_d
    expected_readable = "-0.555"
    assert_equal expected_readable, number.readable
    number = "-0.5555".to_d
    expected_readable = "-0.5555"
    assert_equal expected_readable,
                 number.readable( significant: true )
  end

end
