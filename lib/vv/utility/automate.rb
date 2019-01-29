module VV
  module Automate

    def version path:
      args = ARGV.to_a
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

    def build( name: )
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

  end
end
