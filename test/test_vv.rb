require "minitest/autorun"
require "vv"

class VVTest < Minitest::Test

  def test_load
    assert_equal Module, VV.class
    assert String.vv_included?
  end

end
