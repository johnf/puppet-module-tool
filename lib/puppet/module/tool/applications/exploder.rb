require 'open-uri'
require 'pathname'
require 'tmpdir'
require "digest/sha1"

module Puppet::Module::Tool

  module Applications

    class Exploder < Application
      MODULES     = 'Modules'
      MODULES_DIR = 'modules'

      def initialize(options = {})
        super(options)
      end

      def run
        unless File.exists? MODULES
          abort "Could not locate Modules"
        end

        unless Dir.exists? MODULES_DIR
          abort "Could not locate modules directory"
        end

        modules = Dsl.new(MODULES).evaluate
        modules.each do |mod|
          fetch_module mod
        end
      end

      def fetch_module(mod)
        url = mod.repository.uri + "/users/#{mod.username}/modules/#{mod.name}/releases/find.json"
        #if mod.version_requirement
        #  url.query = "version=#{URI.escape(mod.version_requirement)}"
        #end
        begin
          raw_result = read_url url.to_s
        rescue => e
          abort "Could not find a release for this module (#{e.message})"
        end
        match = PSON.parse(raw_result)

        puts "Installing #{mod.full_name} (#{match['version']})"
        if match['file']
          begin
            cache_path = mod.repository.retrieve(match['file'])
          rescue OpenURI::HTTPError => e
            abort "Could not install module: #{e.message}"
          end
          Unpacker.run(cache_path, File.join(Dir.pwd, MODULES_DIR), options.merge(:quiet => true))
        else
          abort "Malformed response from module repository."
        end
      end

      def read_url(url)
        open(url.to_s).read
      end
    end

    class Dsl
      def evaluate
        contents = File.read(@modulesfile)
        instance_eval(contents)
        @modules
      end

      def initialize(modulesfile)
        @modulesfile = modulesfile
        @source  = nil
        @modules = []
      end

      def source(source)
        unless @source.nil?
          abort 'A source has already been defined'
        end

        case source
        when :puppetlabs then
          source = 'http://forge.puppetlabs.com'
        when String
          source
        end

        @source = source
      end

      def mod(name, *args)
        version = args.first || '>= 0'

        dep = Dependency.new(name, version, @source)

        if (current = @modules.find { |m| m.full_name == dep.full_name }) and current != dep
          abort "You can't include a module twice with different versions or source\nYou included: #{current} and #{dep}."
        end
        unless current
          @modules << dep
        end
      end
    end
  end
end

