require_relative "test_helper.rb"

class LookupTabletest < Minitest::Test

  def test_to_h
    lt = LookupTable.new

    lt[:ca] = { population:  37_000_000 }
    lt[:us] = { population: 325_000_000 }
    lt.alias key: :canada, to: :ca

    response = lt.to_h

    assert_equal Hash, response[:ca].class
    assert_equal Hash, response[:us].class

    assert_includes response[:ca], :data
    assert_includes response[:us], :data

    assert_equal Hash, response[:ca][:data].class
    assert_equal Hash, response[:us][:data].class

    expected_ca_population =  37_000_000
    expected_us_population = 325_000_000

    assert_equal expected_ca_population,
                 response[:ca][:data][:population]
    assert_equal expected_us_population,
                 response[:us][:data][:population]

    assert_includes response[:ca], :aliases
    assert_includes response[:us], :aliases

    assert_equal Array, response[:ca][:aliases].class
    assert_equal Array, response[:us][:aliases].class

    expected_ca_aliases = [:canada]
    expected_us_aliases = []

    assert_equal expected_ca_aliases, response[:ca][:aliases]
    assert_equal expected_us_aliases, response[:us][:aliases]
  end

  def test_method_delegation_to_hash
    lt = LookupTable.new
    lt[:ca] = { population:  37_000_000 }

    refute lt.responds_to? :keys

    expected_keys = [:ca]
    assert_equal expected_keys, lt.keys
  end

  def test_setting_data_via_alias
    lt = LookupTable.new
    lt.alias key: :canada, to: :ca
    population  = { population:  37_000_000 }
    lt[:canada] = population

    assert_includes lt.aliases, :ca
    assert_equal lt.aliases[:ca].first, :canada
    assert_equal population, lt[:ca]
    assert_equal population, lt[:canada]

    lt[:canada][:country] = true
    assert lt[:ca][:country]
    assert lt[:canada][:country]
    assert_equal lt[:ca], lt[:canada]
  end

  def test_bad_alias_exception
    lt = LookupTable.new
    lt.alias key: :canada, to: :ca
    message = \
    assert_raises(RuntimeError) { lt.alias key: :ca, to: :can }.message
    expected_message = \
    "Cannot alias `ca` because 1 others currently alias it."
    assert_equal expected_message, message
  end

  def test_method_missing
    lt = LookupTable.new
    message = assert_raises(NoMethodError) { lt.keyzz }.message

    expected_start = "undefined method `keyzz' for #<LookupTable"
    assert message.starts_with? expected_start

    assert_raises(ArgumentError) { lt.keys 45 }
  end

  def test_includes?
    lt = LookupTable.new
    lt.alias key: :canada, to: :ca
    refute lt.include? :canada
    refute lt.include? :ca
    lt[:ca] = { population:  37_000_000 }
    assert lt.include? :ca
    assert lt.include? :canada
  end

end
