module VV

  class CLI

    attr_reader :option_router,
                :settings,
                :cache_path,
                :config_path,
                :data_path,
                :verbosity

    def initialize version: nil,
                   name: nil,
                   argv: nil,
                   config_path: nil,
                   cache_path:  nil,
                   data_path:   nil

      default_version = "0.0.1"
      @version = version || default_version

      @config_path = config_path
      @cache_path  = cache_path
      @data_path   = data_path

      @option_router = OptionRouter.new( name: name ) do |router|
        yield router if block_given?
      end

      @settings = nil

      self.set_default_paths

      # Most of the time we want to just initialize the
      # thing fully, but it's helpful to test and debug if
      # we're not forced to.
      self.parse_flags argv unless argv.nil?
    end

    def set_default_paths
      @config_path ||= File.config_home! name_version
      @cache_path  ||= File.cache_home!  name_version
      @data_path   ||= File.data_home!   name_version
    end

    def name
      @option_router.name
    end

    def name_version
      [ self.name.unstyled, @version ].join("-")
    end

    def parse_flags argv
      argv = argv.split " " if argv.is_a? String
      @settings = @option_router.parse argv
      set_verbosity
    end

    def set_normal_verbosity
      @verbosity = :normal
    end

    def set_verbosity
      verbosity_flags = %w[ -v -vv -vvv -q -s ]
      flag_set = @settings.keys.includes_any? verbosity_flags
      return self.set_normal_verbosity unless flag_set

      @settings.keys.includes_one! verbosity_flags

      flag = (@settings.keys & verbosity_flags).first


      index = verbosity_flags.index(flag)
      @verbosity = %i[ verbose
                       very_verbose
                       very_very_verbose
                       quiet
                       absolute_silence ][index]
    end

    def await_input message: nil,
                    force_match: false,
                    input: nil

      input   = input
      input ||= Readline.prompt message

      @prompt_message   = message.unstyled
      @prompt_message ||= ""

      response = self.parse_message! input: input

      @prompt_message = nil

      response
    end

    def parse_message! input:
      @prompt_table = LookupTable.new ignore_case: true
      options = @prompt_message.split(String.colon).last
      tokens  = options.split_english

      tokens.each do |_token|
        token = _token.gsub("(","").gsub(")","")
        alias_token = _token.split("(")[-1].split(")")[0]
        @prompt_table[token] = true
        @prompt_table.alias key: alias_token, to: token
      end

      response = @prompt_table.lookup_key input

      response || input
    end

    def help?
      return false if @settings.nil?
      @settings["-h"]
    end

    def version?
      return false if @settings.nil?
      @settings["-V"]
    end

    def print_help width: 80
      option_router.help_doc.cli_print width: width
    end

    def print_version width: 80
      "#{self.name} version #{@version}".cli_puts
    end

  end

  class OptionRouter

    attr_reader :flag_settings, :name

    attr_accessor :version, :help, :testing

    def initialize name: nil
      @flag_settings = LookupTable.new
      @commands = Hash.new
      @current_flag = nil

      @name   = name
      @name ||= "check".style :lightblue, :italic

      self.set_reserved_flags
      self.set_reserved_commands

      yield self if block_given?
    end

    def register flags, type: :string
      flags = [ flags.to_s ] unless flags.is_a? Array
      type.one_of! :string,
                   :integer,
                   :decimal,
                   :float,
                   :boolean,
                   :trilean,
                   :ternary,
                   :reserved

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

        message = "Duplicate flag `#{flag}` cannot be set."
        fail message if type_ok
        fail "Reserved flag `#{flag}` cannot be set."
      end

      settings = { type: type }
      settings[:help] = help unless help.blank?

      @flag_settings[first_flag] = settings
    end

    def set_new_flag
      message = \
      "Duplicate command line flag #{@flag} encountered."

      @flag = lookup_canonical_flag @flag
      fail message if @parsed_arguments.include? @flag

      self.set_flag
    end

    def set_flag
      @flag = lookup_canonical_flag @flag

      @current_flag = @flag if @value.nil?

      self.set_value
    end

    def set_value
      value   = @value
      value &&= @value.to_d if decimal?
      value ||= true
      @parsed_arguments[@flag] = value
    end

    # This needs a refactor.
    def parse argv
      @flags_cease = false
      @parsed_arguments = {}

      argv.each do |arg|
        next add_input_arg arg if @flags_cease

        @flag, *@value = arg.split String.equals_sign
        self.standardize_value

        next @flags_cease = true if self.termination_flag?
        next handle_command if @commands.include? @flag
        next set_flag  if @flag_settings.include? @flag

        self.ensure_known_flag!

        next handle_short_flags if self.short_flag?
        next handle_current     if @current_flag.present?

        self.cease_flag_consideration
      end

      @flag = @value = @current_flag = nil

      @parsed_arguments
    end

    def end_of_commands
      "--"
    end

    def reserve flags
      register flags, type: :reserved
    end

    def create_flag flag, type: nil
      raise NotImplementedError
    end

    def set_reserved_commands
      set_command :help,    alias_flag: "-h"
      set_command :version, alias_flag: "-V"
    end

    def set_reserved_flags
      [ %w[ -h -?  --help              ],
        %w[ -V     --version           ],
        %w[ -v     --verbose           ],
        %w[ -vv    --very-verbose      ],
        %w[ -vvv   --very-very-verbose ],
        %w[ -q     --quiet             ],
        %w[ -s -qq --absolute-silence  ],
        %w[ -- ] ].each do |flags|

        self.register flags, type: :reserved
      end
    end

    def set_command command, alias_flag: nil
      command = command.to_s
      if @commands.include? command
        raise "Command #{command} already set."
      end

      @commands[command] = [ :alias_flag, alias_flag ]
    end

    def lookup_canonical_flag flag
      @flag_settings.lookup_canonical flag
    end

    def help_doc
      ending_flag = %w[ -- ]
      keys  = @flag_settings.canonical_keys - ending_flag
      keys += ending_flag

      cli_flags = keys.map do |key|
        flags = [ key ] + @flag_settings.aliases[key].to_a
        "[#{flags.join(" | ")}]"
      end

      { "usage: #{@name}" => cli_flags }
    end

    def termination_flag?
      @flag == "--"
    end

    def handle_command
      command = @commands[@flag]

      if command.first == :alias_flag
        @flag = command.second
        self.set_flag
      else
        raise NotImplementedError
      end
    end

    def handle_short_flags
      short_flags = \
      @flag.after(String.dash).split String.empty_string

      duplicates = \
      short_flags.count != short_flags.uniq.count

      message = \
      "Duplicate command line flags in #{@flag}."
      fail message if duplicates
    end

    def handle_current

      @value = @flag
      @flag  = @current_flag

      collection = \
      @flag_settings[@flag][:type] == :collection
      if collection
        @parsed_arguments[@flag] ||= []
        @parsed_arguments[@flag] << @value
      else
        @current_flag = nil
        self.set_flag
      end

    end

    def add_input_arg arg
      @parsed_arguments[:input_arguments] ||= []
      @parsed_arguments[:input_arguments] << arg
    end

    def standardize_value
      present = @value.present?
      @value = @value.join( String.equals_sign ) if present
      @value = nil unless @value.present?
    end

    def short_flag?
      return false if long_flag?
      @flag.starts_with? String.dash
    end

    def long_flag?
      @flag.starts_with? 2.dashes
    end

    def ensure_known_flag!
      message = "Unknown flag `#{@flag}` provided."
      fail message if @value.present? or self.long_flag?
    end

    def cease_flag_consideration
      @flags_cease  = true
      @current_flag = nil
      @flag.concat String.equals_sign, @value if @value
      add_input_arg @flag
      @flag = @value = nil
    end

    def flag_type
      @flag_settings[@flag][:type]
    end

    def decimal?
      flag_type == :decimal
    end
  end

end
