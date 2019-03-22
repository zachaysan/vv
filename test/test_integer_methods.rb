require_relative "test_helper.rb"

class IntegerMethodsTest < Minitest::Test

  def test_spaces
    space_count = 3
    expected_spaces = "   "
    assert_equal space_count, expected_spaces.size
    assert_equal expected_spaces, space_count.spaces
  end

  def test_to_i!
    four = 4
    assert_equal four, four.to_i!
  end

  def test_dashes
    assert_equal "-", 1.dashes
    assert_equal "---", 3.dashes
    assert_equal "", 0.dashes
    assert_equal "", -0.dashes
    assert_equal "", -4.dashes
  end

  def test_characters
    assert_equal "@@@", 3.characters("@")
    message = assert_raises(RuntimeError) {
      -3.characters( "@", fail_on_negative: true )
    }.message
    expected_message = "Expected non-negative integer, not `-3`."
    assert_equal expected_message, message
  end

  def test_readable_number
    [         3456,         "3456",
            23_456,       "23,456",
           230_456,      "230,456",
         2_230_456,    "2,230,456",
        22_230_456,   "22,230,456",
       -22_230_456,  "-22,230,456",
      -220_230_456, "-220,230,456",
              -456,         "-456",
             -4560,        "-4560",
           -34_560,      "-34,560" ].each_slice(2)
      .map do | elem |
      number, expected_readable = elem
      assert_equal expected_readable, number.readable
    end
  end

  def test_byte_helpers
    one_byte   = 1
    eight_bits = 8
    assert_equal one_byte, eight_bits.bits

    seven_bits = 7
    assert_equal one_byte, seven_bits.bits

    two_bytes = 2
    nine_bits = 9
    assert_equal two_bytes, nine_bits.bits

    one_kib_in_bytes = 1024
    assert_equal one_kib_in_bytes, 1.kibibyte

    two_kib_in_bytes = 2048
    assert_equal two_kib_in_bytes, 2.kibibytes
    assert_equal two_kib_in_bytes, 2.KiB

    one_mib_in_bytes = 1024 ** 2
    assert_equal one_mib_in_bytes, 1.mebibyte

    two_mib_in_bytes = one_mib_in_bytes * 2
    assert_equal two_mib_in_bytes, 2.mebibytes
    assert_equal two_mib_in_bytes, 2.MiB

    one_gib_in_bytes = 1024 ** 3
    assert_equal one_gib_in_bytes, 1.gibibyte

    two_gib_in_bytes = one_gib_in_bytes * 2
    assert_equal two_gib_in_bytes, 2.gibibytes
    assert_equal two_gib_in_bytes, 2.GiB

    one_tib_in_bytes = 1024 ** 4
    assert_equal one_tib_in_bytes, 1.tebibyte

    two_tib_in_bytes = one_tib_in_bytes * 2
    assert_equal two_tib_in_bytes, 2.tebibytes
    assert_equal two_tib_in_bytes, 2.TiB

    one_pib_in_bytes = 1024 ** 5
    assert_equal one_pib_in_bytes, 1.pebibyte

    two_pib_in_bytes = one_pib_in_bytes * 2
    assert_equal two_pib_in_bytes, 2.pebibytes
    assert_equal two_pib_in_bytes, 2.PiB

    one_eib_in_bytes = 1024 ** 6
    assert_equal one_eib_in_bytes, 1.exbibyte

    two_eib_in_bytes = one_eib_in_bytes * 2
    assert_equal two_eib_in_bytes, 2.exbibytes
    assert_equal two_eib_in_bytes, 2.EiB
  end

end
