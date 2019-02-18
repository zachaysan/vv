module VV
  module FileMethods

    def self.check_file_methods
      ClassMethods.public_instance_methods.each do |method|
        next if method.to_s.starts_with? "vv_"

        message = \
        "File defines method already, cowardly exiting."
        fail message if File.respond_to? method
      end
    end

    def self.included(base)
      self.check_file_methods if base == File

      base.extend(ClassMethods)
    end

    module ClassMethods

      def vv_included?
        true
      end

      def vv_readlines *args, **kwargs
        File.readlines(*args, **kwargs).map!(&:chomp)
      end

      def vv_split string
        response = string.split(File::SEPARATOR)
        response[0] = File::SEPARATOR if response.first.blank?
        response
      end

      def repo_directory missing_throws_exception: true
        _path = caller_locations(1)[0].path
        _file_directory = File.expand_path(File.dirname(_path))

        directory_fragments = File.vv_split _file_directory

        while directory_fragments.any?
          current_directory = File.join directory_fragments

          supported_source_control_directories = %w(.git .hg)

          supported_source_control_directories
            .each do | directory |
            full_path = File.join current_directory, directory
            path_exists = File.directory? full_path
            return current_directory if path_exists
          end

          directory_fragments.pop
        end

        return unless missing_throws_exception

        fail "No repository detected"
      end

      def file_directory
        File.expand_path(File.dirname(caller_locations[0].path))
      end

      def file
        caller_locations[0].path
      end

      def pwd
        File.expand_path(Dir.pwd)
      end

      def separator
        File::SEPARATOR
      end

      def copy_into filepath,
                    directory,
                    allow_hidden: true,
                    allow_absolute: true

        message = "Filepath `#{filepath}` is unsafe."
        fail message unless filepath.safe_path?

        message = "Filepath `#{filepath}` is a directory."
        fail message if filepath.is_directory_path?

        message = "No such `#{directory}` directory."
        fail message unless directory.is_directory_path?

        FileUtils.cp filepath, directory
      end

      def rename_directory from,
                           to,
                           allow_hidden: true,
                           allow_absolute: true
        safe   = from.safe_dir_path? allow_hidden: allow_hidden,
                                     allow_absolute: allow_absolute

        safe &&= to.safe_dir_path? allow_hidden: allow_hidden,
                                   allow_absolute: allow_absolute

        message = "Refusing to rename unsafe directory"
        fail message unless safe

        message = "Source #{from} is not a directory"
        fail message unless from.is_directory_path?

        message = "Target directory name `#{to}` already exists"
        fail message if to.is_directory_path?

        return FileUtils.mv from, to

      end
      alias_method :rename_dir, :rename_directory

      # TODO: Think about making a `directory` method on
      #       string so from / to is super clear.
      def move_directory *args, **kwargs
        message = \
        %w[ Moving directories is confusing. Call either
            `rename_directory` or `move_directory_into`
            depending on your needs. There are many aliases. ]
          .spaced

        fail NoMethodError, message
      end

      def move_directory_into dir,
                              into,
                              allow_hidden: true,
                              allow_absolute: true

        safe   = dir.safe_dir_path?  allow_hidden: allow_hidden,
                                     allow_absolute: allow_absolute

        safe &&= into.safe_dir_path? allow_hidden: allow_hidden,
                                     allow_absolute: allow_absolute

        message = "Refusing to rename unsafe directory"
        fail message unless safe

        message = "Target #{into} is not a directory"
        fail message unless into.is_directory_path?

        message = "Source #{dir} is not a directory"
        fail message unless dir.is_directory_path?

        FileUtils.mv dir, into
      end
      alias_method :move_dir_into, :move_directory_into
      alias_method :mv_dir_into,   :move_directory_into

      def config_home
        path   = ENV['XDG_CACHE_HOME']
        return path unless path.blank?
        path ||= File.join ENV['HOME'], ".config"
      end
      alias_method :xdg_config_home, :config_home

      def data_home
        path   = ENV['XDG_DATA_HOME']
        return path unless path.blank?
        path ||= File.join ENV['HOME'], ".local", "share"
      end
      alias_method :output_home,   :data_home
      alias_method :xdg_data_home, :data_home

      def cache_home sub_directory=nil
        response   = ENV['XDG_CACHE_HOME']
        response ||= File.join ENV['HOME'], ".cache"

        return response unless sub_directory

        File.join response, sub_directory
      end
      alias_method :xdg_cache_home, :cache_home

      def cache_home! sub_directory
        path = cache_home sub_directory
        File.make_dir_if_not_exists path
        path
      end
      alias_method :xdg_cache_home!, :cache_home!

      def make_directory_if_not_exists directory
        FileUtils.mkdir_p(directory).first
      end
      alias_method :make_dir_if_not_exists,
                   :make_directory_if_not_exists

      def make_directory directory
        FileUtils.mkdir(directory).first
      end
      alias_method :create_directory, :make_directory
      alias_method :create_dir,       :make_directory
      alias_method :make_dir,         :make_directory

      def remove_directory directory, quiet_if_gone: false
        no_directory_exists = ! directory.is_directory_path?
        return if quiet_if_gone && no_directory_exists
        FileUtils.remove_dir directory
      end
      alias_method :rm_directory, :remove_directory
      alias_method :remove_dir,   :remove_directory
      alias_method :rm_dir,       :remove_directory

    end

    def vv_readlines
      self.class.vv_readlines self
    end

  end
end
