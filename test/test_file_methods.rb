require "minitest/autorun"
require "vv"

class FileMethodsTest < Minitest::Test

  def test_file_included_vv
    assert File.vv_included?
  end

  def test_readlines
    normal_operation = File.readlines __FILE__

    assert_equal normal_operation.first.last, String.newline

    vv_operation = File.vv_readlines __FILE__
    refute_equal vv_operation.first.last, String.newline

    assert_equal normal_operation.first.size,
                 ( vv_operation.first.size + 1 )

    assert_equal normal_operation.size, vv_operation.size

    file = File.new __FILE__
    file.vv_readlines.each_with_index do | line, index |
      assert_equal normal_operation[index].chomp, line
    end
  end

end
