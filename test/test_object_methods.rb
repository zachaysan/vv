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
