module VV

  # Automate runs standalone from the rest of the repo, so
  # the code here intentionally avoids using helpers that
  # VV adds to ruby classes.

  module Automate

    def version path:, argv:
      args = argv.to_a
      lines = File.read(path).split("\n")

      raise "Unknown number of arguments" if args.size > 1
      version = lines[1].split(" = ")[-1].gsub("'","")
      if args.size < 1
        puts version
        exit
      end

      command = args[0]
      weird = version.split(".").size != 3
      raise "Only handles basic versions" if weird

      major, minor, point = version.split(".").map(&:to_i)

      if command == "+"
        point += 1
      elsif command == "++"
        point = 0
        minor += 1
      elsif command == "+++"
        point = 0
        minor = 0
        major += 1
      elsif command.split(".").size == 3
        major, minor, point = command.split(".")
      elsif command == "reset"
        system("git checkout -- #{path}")
        exit
      elsif command == "commit"
        message = "Bump version to #{version}"
        system("git commit -S --only #{path} -m \"#{message}\"")
        exit
      elsif %w[ help --help h -h ].include? command
        puts
        puts "Available commands are:"
        puts
        puts "+   - point increment"
        puts "++  - minor increment"
        puts "+++ - major increment"
        puts
        puts "x.y.z - to set version explicitly"
        puts "reset - to revert to version in git"
        puts
        exit
      end

      new_version = [major, minor, point].join(".")
      lines[1] = "  VERSION = '#{new_version}'"
      lines << ""

      File.write(path, lines.join("\n"))

    end
    module_function :version

    def build( name: , argv: nil )
      simple = %w[ simple force ].include? argv.first
      return build_simple name: name if simple

      puts %x{ find lib/ | \\
         xargs git ls-files --error-unmatch > /dev/null 2>&1 \\
         || ( echo && \\
              echo "Warning: A file in lib/ is not tracked by git" && \\
              echo )

         rm #{name}-*.gem
         gem uninstall --ignore-dependencies #{name} > /dev/null
         bundle
         gem build #{name}.gemspec
         gem install $(readlink -f #{name}-*.gem | sort | tail -n 1 ) --pre
       }
    end
    module_function :build

    def build_simple( name: )
      puts %x{ rm #{name}-*.gem
         gem uninstall --ignore-dependencies #{name} > /dev/null
         gem build --force #{name}.gemspec
         gem install --force --local $(readlink -f #{name}-*.gem | sort | tail -n 1 ) --pre
       }
    end
    module_function :build_simple

    def push( name: )
      puts %x{ TAG_VERSION=$(./bin/version)
               git push origin HEAD && \\
               gem push $(readlink -f #{name}-*.gem | sort | tail -n 1) && \\
               git push origin v${TAG_VERSION}
       }
    end
    module_function :push

    def run command: nil, annoying_command: nil
      command ||= "rake"
      annoying_command ||= command
      args = ARGV.to_a

      # breaking out of binding.pry is hard without exec
      exec command if args.empty?

      return annoying_command(args, command: annoying_command)
    end
    module_function :run

    def annoying_command args, command: nil
      command ||= "rake"

      test_dir = File.join File.expand_path(Dir.pwd), "test"
      temp_test_dir = "temp_test_dir_#{Random.identifier 6}"

      message = "Cannot find test directory `#{test_dir}`."
      fail message unless test_dir.is_directory_path?

      fail "Unexpected arg count" if args.size > 2

      helper_file = "test_helper.rb"
      file, line_number = args

      if line_number.nil?
        file, line_number = file.split(String.colon)[0..1]
      end

      File.rename_directory test_dir, temp_test_dir
      sleep 0.01
      File.make_directory test_dir

      path = file.split(File.separator).last
      new_filename = temp_test_dir.file_join path
      helper_file  = temp_test_dir.file_join helper_file
      File.copy_into new_filename, test_dir
      File.copy_into helper_file,  test_dir

      if line_number
        line_number = line_number.to_i!
        i = j = line_number - 1
        lines = File.vv_readlines test_dir.file_join(path)

        while i > 0
          line = lines[i]
          break if line.start_with? "  def "
          i -= 1
        end

        while j < lines.count
          line = lines[j]
          break if line.start_with? "  end"
          j += 1
        end
        content = (lines[0..3] + lines[i..j] + lines[-2..-1] ).join("\n")
        content += "\n"

        File.write test_dir.file_join(path), content
      end

      full_command = \
        [ command,
          "rm -r #{test_dir}",
          "mv #{temp_test_dir} #{test_dir}" ].join(" && ")

      exec full_command

    # The below shouldn't run in normal operation, since
    # exec will replace the current process
    ensure
      File.remove_directory test_dir
      File.rename_directory temp_test_dir, test_dir
    end
    module_function :annoying_command

  end
end
