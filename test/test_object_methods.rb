require "minitest/autorun"
require "vv"

class ObjectMethodsTest < Minitest::Test

  def test_present
    assert Object.new.present?
  end

  def test_blank
    refute Object.new.blank?
  end

end
