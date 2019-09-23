require_relative "test_helper.rb"

class FloatMethodsTest < Minitest::Test

  def test_vv_json
    simple_float = 0.5
    expected_json = "0.5"
    refute_equal expected_json, simple_float
    assert_equal expected_json, simple_float.vv_json

    nan = Float::NAN
    message = assert_raises(RuntimeError) { nan.vv_json }.message
    expected_message = "NaN not convertable sans `nan_coerces: true`."
    assert_equal expected_message, message

    json = nan.vv_json nan_coerces: true
    null = "null"
    assert_equal null, json

    inf = Float::INFINITY
    message = assert_raises(RuntimeError) { inf.vv_json }.message
    expected_message = \
    %w[ Infinite not convertable sans `infinity_coerces: true`.
        Set `max` and `min` for non-null coercion. ].spaced

    assert_equal expected_message, message

    neg_inf = -inf
    assert inf > neg_inf

    assert_equal null,     inf.vv_json( infinity_coerces: true )
    assert_equal null, neg_inf.vv_json( infinity_coerces: true )

    max = 10_000_000
    assert_equal max.to_s, inf.vv_json( infinity_coerces: true, max: max )
    assert_equal null, neg_inf.vv_json( infinity_coerces: true, max: max )

    min = -1_000_000
    assert_equal null, inf.vv_json( infinity_coerces: true, min: min )
    assert_equal min.to_s,
                 neg_inf.vv_json( infinity_coerces: true, min: min )

  end

  def test_readable_number
    [           -0.05,           "-0.05",
                 0.05,            "0.05",
              3456.05,         "3456.05",
            23_456.05,       "23,456.05",
           230_456.05,      "230,456.05",
         2_230_456.05,    "2,230,456.05",
        22_230_456.05,   "22,230,456.05",
       -22_230_456.05,  "-22,230,456.05",
      -220_230_456.05, "-220,230,456.05",
              -456.05,         "-456.05",
             -4560.99,        "-4560.99",
           -34_560.00,      "-34,560.0" ].each_slice(2)
      .map do | elem |
      number, expected_readable = elem
      assert_equal expected_readable, number.readable
    end

    number = 0.555555555555
    expected_readable = "0.556"
    assert_equal expected_readable, number.readable
    number = 0.555
    expected_readable = "0.555"
    assert_equal expected_readable, number.readable
    number = -0.555
    expected_readable = "-0.555"
    assert_equal expected_readable, number.readable
    number = -0.5555
    expected_readable = "-0.5555"
    assert_equal expected_readable,
                 number.readable( significant: true )

    number = 234566787654.034569543
    expected_readable = "234,566,787,654.035"
    assert_equal expected_readable, number.readable_number
  end

end
