require_relative "test_helper.rb"

class ComplexMethodsTest < Minitest::Test

  def test_load
    assert Complex.vv_included?
  end

  def test_real_digits
    complex = "4.4+5.5i".to_c
    message = assert_raises(RuntimeError) do
      complex.real_digits
    end.message

    expected_message = \
    "Complex number contains imaginary part."
    assert_equal expected_message, message

    expected_digits = "4.4"
    digits = complex.real_digits unsafe: true
    assert_equal expected_digits, digits
  end

end
