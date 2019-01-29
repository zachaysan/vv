require_relative "test_helper.rb"

class TestRandomClass
  include VV::RandomMethods
end

class RandomMethodsTest < Minitest::Test

  def test_random_included_vv
    assert Random.vv_included?
  end

  def test_random_identifier
    expected_length = 10
    random_identifier = Random.identifier expected_length
    assert_equal expected_length, random_identifier.length
  end

  # There is a potential off-by-one error that was hit earlier
  def test_random_identifier_length
    expected_length = 2
    10_000.times do
      random_identifier = Random.identifier expected_length
      assert_equal expected_length, random_identifier.length
    end
  end

  def test_random_identifier_with_default_length
    random_identifier = Random.identifier
    expected_length = 40
    assert_equal expected_length, random_identifier.length
  end

  def test_random_identifer_inclusion
    expected_length = 12
    random_identifier = \
    TestRandomClass.identifier expected_length
    assert_equal expected_length, random_identifier.length
  end

  def test_random_identifer_inclusion_without_default
    assert_raises(NoMethodError) { TestRandomClass.identifier }
  end

  def test_random_character
    random_character = Random.character
    expected_length = 1
    assert_equal expected_length, random_character.length
    assert_includes String.letters_and_numbers, random_character
    expected_length = 4
    random_characters = Random.character expected_length
    assert_equal expected_length, random_characters.length
    expected_length = 40
    random_characters = \
    Random.character expected_length, capitals: true
    assert_equal expected_length, random_characters.length
    assert String.capitals.includes_any?(random_characters)
  end

end
