require_relative "test_helper.rb"

class ArrayMethodsTest < Minitest::Test

  def test_array_included_vv
    assert Array.vv_included?
  end

  def test_blank?
    assert [ ].blank?
    refute [2].blank?
  end

  def test_empty?
    assert [ ].empty?
    refute [2].empty?
  end

  def test_gravify
    to_grave = %w[ to_i to_s ]
    expected = ["`to_i`", "`to_s`"]
    assert_equal expected, to_grave.gravify
    refute_equal expected, to_grave
  end

  def test_gravify!
    to_grave = %w[ to_i to_s ]
    expected = ["`to_i`", "`to_s`"]
    refute_equal expected, to_grave
    to_grave.gravify!
    assert_equal expected, to_grave
  end

  def test_includes_any
    assert [1,2,3].includes_any? [2]
    assert [1,2,3].includes_any? [3,7]
    assert [1,2,3].includes_any? [0,1]
    assert [1,2,3].includes_any? [1,3]

    refute [1,2,3].includes_any? ["2"]
    refute [1,2,3].includes_any? [0,7]
    refute [1,2,3].includes_any? [[1]]
    refute [1,2,3].includes_any? [0,0]

    bananas = { bananas: 2 }
    assert_raises(TypeError) { [1,2,3].includes_any?(bananas) }
    assert_raises(TypeError) { [1,2,3].includes_any?  2  }
    assert_raises(TypeError) { [1,2,3].includes_any? "2" }
  end

  def test_includes_one!
    assert [1,2,3].includes_one? [1]
  end

  def test_stringify_collection
    assert_equal String.empty_string, Array.new.stringify_collection

    collection = [ "green eggs" ]
    expected_string = "green eggs"
    assert_equal expected_string, collection.stringify_collection

    collection << "ham"
    expected_string = "green eggs and ham"
    assert_equal expected_string, collection.stringify_collection

    collection.prepend(*%w[ peace liberty ])

    expected_string = "peace, liberty, green eggs, and ham"
    assert_equal expected_string, collection.stringify_collection

    expected_string = "`peace`, `liberty`, `green eggs`, and `ham`"
    string = collection.stringify_collection grave: true
    assert_equal expected_string, string
  end

  def test_spaced
    assert_equal "2 3 4 5", [2,3,4,5].spaced
    assert_equal "", [].spaced
  end

  def test_format!
    @age = 33
    @color = "pls"
    string = ['age: #{@age}', 'color: #{@color}'].format! self
    expected_string = "age: 33 color: pls"
    assert_equal expected_string, string
  end

end
