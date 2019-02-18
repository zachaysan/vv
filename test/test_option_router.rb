require_relative "test_helper.rb"

class OptionRouterTest < Minitest::Test

  def test_option_router
    option_router = \
    VV::OptionRouter.new do |router|

      router.register %w[ -i --interactive ] do
        "Causes a calamity"
      end

    end

    option_router.register %w[ -r --region ], type: :string do
      "Sets the region"
    end


    expected_canonical_flag = "-r"
    canonical_flag = option_router.lookup_canonical_flag "--region"
    assert_equal expected_canonical_flag, canonical_flag
    canonical_flag = option_router.lookup_canonical_flag "-r"
    assert_equal expected_canonical_flag, canonical_flag

    expected_canonical_flag = "-i"
    canonical_flag = \
    option_router.lookup_canonical_flag "--interactive"
    assert_equal expected_canonical_flag, canonical_flag
    canonical_flag = option_router.lookup_canonical_flag "-i"
    assert_equal expected_canonical_flag, canonical_flag
  end

  def test_option_router_help
    option_router = VV::OptionRouter.new do |router|
      router.help = "A friendly CLI."
    end

    doc = option_router.help_doc
    printed = String.get_stdout { doc.cli_print width: 70 }

    check = "\e[38;2;173;216;230m\e[3mcheck\e[0m"

    usage   = "usage: #{check}"
    help    = "[-h | -? | --help]"
    version = "[-V | --version]"
    verbose = "[-v | --verbose]"
    first   = "#{usage} #{help} #{version} #{verbose}"

    pad = usage.unstyled.length.spaces
    vv  = "[-vv | --very-verbose]"
    vvv = "[-vvv | --very-very-verbose]"
    second = "#{pad} #{vv} #{vvv}"

    quiet = "[-q | --quiet]"
    qq    = "[-s | -qq | --absolute-silence]"
    stop  = "[--]"
    third = "#{pad} #{quiet} #{qq} #{stop}"
    expected_strings = [ first, second, third ]

    printed.split(String.newline).each_with_index do |elem, index|
      assert_equal expected_strings[index], elem
    end
  end

  def test_parse_for_help
    option_router = VV::OptionRouter.new
    option_router.testing = true
    argv = ["--help"]
    response = option_router.parse argv

    expected_response = { "-h" => true }
    assert_equal expected_response, response
  end

  def test_help_command_alias
    option_router = VV::OptionRouter.new
    argv = ["help"]
    response = option_router.parse argv
    expected_response = { "-h" => true }
    assert_equal expected_response, response
  end

  def test_unknown_flag_exception
    option_router = VV::OptionRouter.new
    argv = %w[ --dry-run -vvv file.json ]

    message = assert_raises(RuntimeError) {
      option_router.parse argv
    }.message

    expected_message = "Unknown flag `--dry-run` provided."
    assert_equal expected_message, message
  end

  def test_unknown_flag_exception_with_value
    option_router = VV::OptionRouter.new
    argv = %w[ --dry-run=yesthx -vvv file.json ]

    message = assert_raises(RuntimeError) {
      option_router.parse argv
    }.message

    expected_message = "Unknown flag `--dry-run` provided."
    assert_equal expected_message, message
  end

  def test_complex_parsing
    option_router = VV::OptionRouter.new

    argv = \
    %w[ --fx 2.45 --in USD --out CAD bank1.log bank2.log ]

    option_router.register "--fx", type: :decimal

    message = assert_raises(RuntimeError) {
      option_router.parse argv
    }.message

    expected_message = "Unknown flag `--in` provided."
    assert_equal expected_message, message

    option_router.register %w[ -i --in  ]

    message = assert_raises(RuntimeError) {
      option_router.parse argv
    }.message

    expected_message = "Unknown flag `--out` provided."
    assert_equal expected_message, message

    message = assert_raises(RuntimeError) {
      option_router.register %w[ -i --out ], type: :string
    }.message

    expected_message = "Duplicate flag `-i` cannot be set."
    assert_equal expected_message, message

    option_router.register %w[ -o --out ], type: :string

    settings = option_router.parse argv
    expected_settings = { "--fx"=>0.245e1,
                          "-i"=>"USD",
                          "-o"=>"CAD",
                          input_arguments: ["bank1.log",
                                            "bank2.log"] }
    assert_equal expected_settings, settings

  end

  def test_addition_argv
    option_router = VV::OptionRouter.new
    simple_argv = %w[ 34.6 456 345 45 ]
    settings = option_router.parse simple_argv
    expected_settings = \
    { input_arguments: ["34.6", "456", "345", "45"] }
    assert_equal expected_settings, settings
  end

  def test_file_argv
    option_router = VV::OptionRouter.new
    argv = %w[ -- Gemfile Gemfile.lock ]
    settings = option_router.parse argv
    expected_settings = \
    { input_arguments: ["Gemfile", "Gemfile.lock"] }
    assert_equal expected_settings, settings
  end

end
