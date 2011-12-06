require 'open-uri'
require 'pathname'
require 'tmpdir'
require "digest/sha1"

module Puppet::Module::Tool

  module Applications

    class Exploder < Application
      MODULES = 'Modules'

      def initialize(options = {})
        super(options)
      end

      def run
        unless File.exists? MODULES
          puts "Could not locate Modules"
          return
        end

        modules = Dsl.new(MODULES).evaluate
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
        @modules << dep
      end
    end
  end
end

