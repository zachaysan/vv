require "minitest/autorun"
require "vv"

class FileMethodsTest < Minitest::Test

  def test_file_included_vv
    assert File.vv_included?
  end

  def test_vv_readlines
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

  def test_vv_split
    unixy = ! Gem.win_platform?
    path1 = unixy ? "/test/string/one" : '\test\string\one'
    path2 = unixy ? "local/string/two" : 'local\string\two'

    split1 = File.vv_split path1
    split2 = File.vv_split path2

    expected_split1 = %w[ /  test string one ]
    expected_split2 = %w[   local string two ]

    assert_equal expected_split1, split1
    assert_equal expected_split2, split2
  end

  def test_repo_directory
    directory = File.repo_directory
    expected_directory = File.expand_path(__dir__)
    expected_directory.chomp! "/test"
    assert_equal expected_directory, directory
  end

  def test_file_directory
    directory = File.file_directory
    expected_directory_fragment = "vv/test"
    assert directory.ends_with? expected_directory_fragment
    assert directory.size > expected_directory_fragment.size
  end

  def test_file
    path = File.file
    expected_path_fragment = "vv/test/test_file_methods.rb"
    assert path.ends_with? expected_path_fragment
    assert path.size > expected_path_fragment.size
  end

  def test_pwd
    directory = File.pwd
    expected_pwd = `pwd`.chomp
    assert_equal expected_pwd, directory
    expected_directory = File.expand_path(__dir__)
    expected_directory.chomp! "/test"
    assert_equal expected_directory, directory
  end

end
