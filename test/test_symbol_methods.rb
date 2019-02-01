require_relative "test_helper.rb"

class SymbolMethodsTest < Minitest::Test

  def test_one_of!
    assert :dog.one_of!( :cat, :dog, :bunny )

    message = assert_raises(RuntimeError){
      :dog.one_of!( :hat, :tree, :bugs )
    }.message

    expected_message = \
    "Symbol `dog` is invalid. Must be one of: `hat`, `tree`, and `bugs`."

    assert_equal expected_message, message

    message = assert_raises(ArgumentError){
      :dog.one_of!( :cat, "dog", :bunny )
    }.message

    expected_message = "Invalid types: Symbol collection required."
    assert_equal expected_message, message
  end

  def test_insta
    expected_insta = "@dog"
    assert_equal expected_insta,  :dog.insta
    assert_equal expected_insta, :@dog.insta
  end

  def test_insta_sym
    expected_insta_sym = :@dog
    assert_equal expected_insta_sym,  :dog.insta_sym
    assert_equal expected_insta_sym, :@dog.insta_sym
  end

end
