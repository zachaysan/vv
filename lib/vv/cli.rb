module VV

  class CLI

    attr_reader :option_router

    def initialize

      @option_router = OptionRouter.new do |router|
        yield router
      end

    end

  end

  class OptionRouter

    attr_reader :flag_settings

    attr_accessor :version, :help

    def initialize name: nil
      @flag_settings = LookupTable.new
      @name = "check".style :lightblue, :italic

      self.set_reserved_flags

      yield self if block_given?
    end

    def register flags, type: :string
      flags = [ flags.to_s ] unless flags.is_a? Array
      type.one_of! :string, :integer, :boolean, :reserved
      help = block_given? ? yield.squish : nil

      first_flag = flags.first

      flags.each do |flag|
        if @flag_settings[flag].blank?
          next if flag == first_flag
          @flag_settings.alias key: flag, to: first_flag
          next
        end

        set_type = @flag_settings[flag][:type]
        type_ok = set_type != :reserved

        fail "Duplicate flag `#{flag}` cannot be set." if type_ok
        fail "Reserved flag `#{flag}` cannot be set."
      end

      settings = { type: type }
      settings[:help] = help unless help.blank?

      @flag_settings[first_flag] = settings
    end

    def reserve flags
      register flags, type: :reserved
    end

    def set_flag flag, type: nil
      raise NotImplemented
    end

    def set_reserved_flags
      [ %w[ -h -?  --help      help    ],
        %w[ -V     --version   version ],
        %w[ -v     --verbose           ],
        %w[ -vv    --very-verbose      ],
        %w[ -vvv   --very-very-verbose ],
        %w[ -q     --quiet             ],
        %w[ -s -qq --absolute-silence  ] ].each do |flags|

        self.register flags, type: :reserved
      end
    end

    def lookup_canonical_flag flag
      @flag_settings.lookup_canonical flag
    end

    def help_doc
      keys = @flag_settings.canonical_keys

      cli_flags = keys.map do |key|
        flags = [ key ] + @flag_settings.aliases[key].to_a
        "[#{flags.join(" | ")}]"
      end

      { "usage: #{@name}" => cli_flags }
    end

  end

end
