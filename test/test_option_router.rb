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
    first_line = \
    "usage: #{check} [-h | -? | --help | help] [-V | --version | version]"

    expected_strings = [
      first_line,
      "             [-v | --verbose] [-vv | --very-verbose]",
      "             [-vvv | --very-very-verbose] [-q | --quiet]",
      "             [-s | -qq | --absolute-silence]" ]

    printed.split(String.newline).each_with_index do |elem, index|
      assert_equal expected_strings[index], elem
    end
  end

end
