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

  def test_with_named_cli_app
    name = "super"
    cli = VV::CLI.new name: name

    argv = "--dry-run -vvv file.json"
    message = \
    assert_raises(RuntimeError) { cli.parse_flags argv }.message

    expected_message = "Unknown flag `--dry-run` provided."
    assert_equal expected_message, message

    assert_equal name, cli.option_router.name
    assert_equal name, cli.name

    assert_nil cli.settings
    cli.parse_flags "-vvv"
    refute_nil cli.settings
    assert cli.settings["-vvv"]
  end

  def test_with_default_locations
    version = "0.2.3"
    name = "super"
    cli = VV::CLI.new version: version, name: "super"
    expected_dirname = "#{name}-#{version}"
    expected_config_path = File.join File.config_home, expected_dirname
    assert_equal expected_config_path, cli.config_path
    expected_cache_path = File.join File.cache_home, expected_dirname
    assert_equal expected_cache_path, cli.cache_path
    expected_data_path = File.join File.data_home, expected_dirname
    assert_equal expected_data_path, cli.data_path
  end

end
