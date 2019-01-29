require_relative "test_helper.rb"

class ReadlineMethodsTest < Minitest::Test

  def test_readline_included_vv
    assert Readline::vv_enabled?
  end

  # TODO: Implement tests for prompt methods

end
