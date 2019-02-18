require_relative "test_helper.rb"

class ObjectMethodsTest < Minitest::Test

  def test_present
    assert Object.new.present?
  end

  def test_blank
    refute Object.new.blank?
  end

  def test_cli_printable
    object = Object.new
    message = assert_raises(NoMethodError) do
      object.cli_printable
    end.message
    expected_message = \
    "`cli_printable` requires `cli_print` on child class"
    assert_equal expected_message, message
  end

end
