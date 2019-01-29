require_relative "test_helper.rb"

class ObjectMethodsTest < Minitest::Test

  def test_present
    assert Object.new.present?
  end

  def test_blank
    refute Object.new.blank?
  end

end
