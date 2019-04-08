require_relative "test_helper.rb"

class ObjectMethodTestable
  attr_reader   :my_attr1
  attr_writer   :my_attr2
  attr_accessor :my_attr3
end

class ObjectMethodsTest < Minitest::Test

  def test_present
    assert Object.new.present?
  end

  def test_blank
    refute Object.new.blank?
  end

  def test_cli_printable
    object = Object.new
    message = assert_raises(NoMethodError) do
      object.cli_printable
    end.message
    expected_message = \
    "`cli_printable` requires `cli_print` on child class"
    assert_equal expected_message, message
  end

  def test_consider
    expected_input = input = "banana"
    other_input = "apple"
    input_matched = consideration_encountered = false

    consider input do
      consideration_encountered = true
      given other_input do
        assert false
      end

      given expected_input do
        input_matched = true
      end

      given expected_input do
        assert false
      end

      otherwise do
        assert false
      end
    end

    assert consideration_encountered, "Consider broken"
    assert input_matched, "Expected given did not match"
  end

  def test_nested_consider
    expected_input = input = "racecar"
    other_input = "bicycle"
    input_matched = consideration_encountered = false

    consider other_input do
      given other_input do
        consider input do
          consideration_encountered = true

          given other_input do
            assert false
          end

          given expected_input do
            input_matched = true
          end
        end
      end
    end

    assert consideration_encountered, "Consider broken"
    assert input_matched, "Expected given did not match"
  end

  def test_consider_otherwise
    input = "moneyz"
    other_input = "serious corporate plan"
    otherwise_matched = consideration_encountered = false

    consider input do
      consideration_encountered = true
      given other_input do
        assert false
      end

      otherwise do
        otherwise_matched = true
      end
    end

    assert otherwise_matched, "Otherwise did not match"
    assert consideration_encountered, "Consider broken"
  end

  def test_deeply_nested_consideration
    input = Integer

    correct = []
    consider(input) { given(43) { correct << false } }
    consider(input) {
      given(Integer) {
        consider(33) {
          otherwise {
            consider 44 do
              given(44) {
                consider(input) {
                  given(Numeric) {
                    correct << false
                  }
                  otherwise {
                    correct << true
                  }
                }
              }
              given 44 do
                correct << false
              end
              otherwise {
                correct << false
              }
            end
          }
        }
      }
    }

    self.instance_variables.each do | var |
      message = "Unexpected vv instance variable `#{var}` still defined."
      refute var.to_s.start_with?("@__vv_"), message
    end

    expected_size = 1
    assert_equal expected_size, correct.size
    assert correct.first
  end

  def test_multiple_otherwise
    correct = false
    error   = nil
    consider(3) {
      given(4)  { assert false }
      otherwise { correct = true }
      error = \
      assert_raises(RuntimeError) { otherwise { correct = false } }
    }
    expected_message = "Multiple otherwise methods in consideration."
    assert correct
    assert_equal expected_message, error.message
  end

  def test_consideration_within
    correct = false
    consider(3) {
      given(4) {
        assert false
      }
      within(55..60) {
        assert false
      }
      within(1..5) {
        correct = true
      }
      otherwise {
        assert false
      }
    }
    assert correct
  end

  def test_set_attrs_via
    object = ObjectMethodTestable.new
    my_attr1 = 45
    refute_equal my_attr1, object.my_attr1

    object.set_attrs_via :my_attr1, document: { my_attr1: my_attr1 }
    assert_equal my_attr1, object.my_attr1

    my_attr2 = :hello
    my_attr3 = [2,3,4,5]

    document = { my_attr2: my_attr2,
                 my_attr3: my_attr3 }

    object.set_attrs_via :my_attr2,
                         :my_attr3,
                         document: document

    assert_equal my_attr1, object.my_attr1
    assert_equal my_attr2,
                 object.instance_variable_get(:my_attr2.insta_sym)
    assert_equal my_attr3, object.my_attr3

    message = assert_raises(RuntimeError) {
      object.set_attrs_via :my_attr1,
                           :my_attr2,
                           :my_attr3,
                           document: document
    }.message

    expected_message = "Collection does not include: `my_attr1`."
    assert_equal expected_message, message
  end

end
