require_relative "test_helper.rb"

class ArrayMethodsTest < Minitest::Test

  def test_set_included_vv
    assert Set.vv_included?
  end

  def test_set_includes_one?
    assert Set.new([1,2,3]).includes_one? [2]
    assert Set.new([1,2,3]).includes_one? Set.new([2])
    refute Set.new([1,2,3]).includes_one? [9]
    refute Set.new([1,2,3]).includes_one? Set.new([9])
  end

  def test_set_include_any?
    set = Set.new([1,2,3])
    assert set.include_any? set
    assert set.include_any? [2]
    assert set.include_any? Set.new([2])
    assert set.include_any? [2,3]
    assert set.include_any? Set.new([2,3])
    assert set.include_any? [2,3,199]
    assert set.include_any? Set.new([2,3,199])
    refute set.includes_one? [9]
    refute set.includes_one? Set.new([9])
    refute set.includes_one? []
    refute set.includes_one? Set.new
  end

  def test_set_include_any!
    set = Set.new([1,2,3])
    assert set.include_any! [2,9]
    message = assert_raises(RuntimeError) { set.include_any! [8] }.message
    expected_message = \
    "Collections did not share exactly any elements."
    assert_equal expected_message, message
  end

  def test_set_includes_all?
    set = Set.new([1,2,3])
    assert set.includes_all? [2,3]
    assert set.includes_all? [1,3]
    assert set.includes_all? [1,3].to_set
    assert set.includes_all? [1,2,3]
    assert set.includes_all? [2,3,1]
    assert set.includes_all? Set.new([2,3,1])
    refute set.includes_all? [1,2,3,6]
    refute set.includes_all? [2,4,1]
    refute set.includes_all? Set.new([0,3,1])
  end

  def test_set_include_all!
    set = Set.new([1,2,3])
    assert set.include_all! [1,3,2]
    assert set.include_all! Set.new([1,3,2])

    message = assert_raises(RuntimeError) { set.include_all! [8] }.message
    expected_message = "Collection does not include: `8`."
    assert_equal expected_message, message

    message = assert_raises(RuntimeError) { set.include_all! [12,8] }.message
    expected_message = "Collection does not include: `12` and `8`."
    assert_equal expected_message, message
  end

end
