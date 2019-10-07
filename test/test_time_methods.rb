require_relative "test_helper.rb"

class TimeMethodsTest < Minitest::Test

  def test_load
    assert Time.vv_included?
  end

  def test_second
    nowish = Time.now
    assert_equal nowish.sec, nowish.second
  end

  def test_sub_second
    nowish = Time.now
    assert_equal nowish.subsec, nowish.sub_second
  end

end
