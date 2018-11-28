require "minitest/autorun"
require "vv"

class VVTest < Minitest::Test

  def test_load
    assert String.vv_included?
  end

end
