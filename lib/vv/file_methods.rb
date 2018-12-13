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
        directory_fragments = File.vv_split self.file_directory

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
        File.dirname caller_locations[0].path
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

    end

    def vv_readlines
      self.class.vv_readlines self
    end

  end
end
