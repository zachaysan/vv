require_relative "test_helper.rb"

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

  def test_move_directory
    message = \
    assert_raises(NoMethodError) { File.move_directory }
      .message

    expected_message = \
    "Moving directories is confusing. Call either "  +
    "`rename_directory` or `move_directory_into` "   +
    "depending on your needs. There are many aliases."

    assert_equal expected_message, message
  end

  def test_move_directory_into
    base = File.cache_home! "vv_tests"

    into = base.file_join "needs_tests"
    from = base.file_join "testytest"

    expected_into = \
    File.join ENV['HOME'], ".cache", "vv_tests", "needs_tests"
    assert_equal expected_into, into

    from_ending = "testytest"
    expected_from = \
    File.join ENV['HOME'], ".cache", "vv_tests", from_ending
    assert_equal expected_from, from

    into_response = File.create_directory into
    assert_raises(Errno::EEXIST) { File.make_dir into }
    assert_equal expected_into, into_response

    from_response = File.create_directory from
    assert_raises(Errno::EEXIST) { File.make_dir from }
    assert_equal expected_from, from_response
    File.move_directory_into from, into

    assert into.is_directory_path?
    refute from.is_directory_path?
    assert File.join(into, from_ending).is_directory_path?
  ensure
    File.remove_directory from, quiet_if_gone: true
    File.remove_directory into, quiet_if_gone: true
  end

  def test_rename_directory
    base = File.cache_home! "vv_tests"

    dir = base.file_join "needs_tests"
    refute dir.is_directory_path?
    File.make_dir dir
    assert dir.is_directory_path?

    new_dir = base.file_join "no_tests_pls"
    refute new_dir.is_directory_path?
    File.rename_directory dir, new_dir
    refute dir.is_directory_path?
    assert new_dir.is_directory_path?
  ensure
    File.remove_directory base
  end

  def test_make_directory_if_not_exists
    base = File.cache_home! "vv_tests"
    new_directory = "gandalf"
    dir = base.file_join new_directory
    refute dir.is_directory_path?
    File.make_directory_if_not_exists dir
    assert dir.is_directory_path?
    File.make_directory_if_not_exists dir
    assert dir.is_directory_path?
  end

  def test_make_directory
    base = File.cache_home! "vv_tests"
    new_directory = "gandalf"
    dir = base.file_join new_directory
    refute dir.is_directory_path?
    File.make_directory dir
    assert dir.is_directory_path?

    message = assert_raises(Errno::EEXIST) {
      File.make_directory dir
    }.message

    assert message.starts_with? "File exists @ dir_s_mkdir"
  ensure
    File.remove_directory base
  end

  def test_remove_directory
    base = File.cache_home! "vv_tests"
    new_directory = "gandalf"
    dir = base.file_join new_directory
    refute dir.is_directory_path?
    File.remove_directory dir, quiet_if_gone: true
    File.make_directory dir
    assert dir.is_directory_path?
    File.remove_directory dir
    refute dir.is_directory_path?
  ensure
    File.remove_directory base
  end

end
