require_relative "test_helper.rb"

class VVJsonTest < Minitest::Test

  def test_empty_hash_json
    expected_json = "{}"
    assert_equal expected_json, Hash.new.vv_json
  end

  def test_empty_array_json
    expected_json = "[]"
    assert_equal expected_json, Array.new.vv_json
  end

  def test_string_json
    expected_json = '"json"'
    assert_equal expected_json, 'json'.vv_json
  end

  def test_integer_json
    expected_json = "45"
    assert_equal expected_json, 45.vv_json
  end

  def test_nil_json
    expected_json = "null"
    assert_equal expected_json, nil.vv_json
  end

  def test_float_json
    expected_json = "3.5"
    assert_equal expected_json, 3.5.vv_json
  end

  def test_complex_json
    properties = { age: 34,
                   rank: "captain",
                   kind: :person,
                   balances: [ 30_345.50, 222.50 ],
                   gender: nil,
                   friends: { best: "Gary", worst: "Frank" } }
    json = properties.vv_json
    expected_json = \
    '{"age":34,"rank":"captain","kind":"person",' +
    '"balances":[30345.5,222.5],"gender":null,'   +
    '"friends":{"best":"Gary","worst":"Frank"}}'

    assert_equal expected_json, json

    expected_parsed_json = \
    {"age"=>34,
     "rank"=>"captain",
     "kind"=>"person",
     "balances"=>[30345.5, 222.5],
     "gender"=>nil,
     "friends"=>{"best"=>"Gary", "worst"=>"Frank"}}

    assert_equal expected_parsed_json, json.parse_json
  end

end
