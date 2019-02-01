require_relative "test_helper.rb"

class CLITest < Minitest::Test

  def test_cli_option_router_settings
    cli = VV::CLI.new do |option_router|
      option_router.register %w[ -x --xray --x-ray ], type: :boolean do
        "Enable x-rays"
      end
    end

    expected_canonical_flag = "-x"
    [ "-x", "--xray", "--xray" ].each do |flag|
      canonical_flag = cli.option_router.lookup_canonical_flag flag
      assert_equal expected_canonical_flag, canonical_flag
    end
  end

end
