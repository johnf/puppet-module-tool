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
        modules.each {|m| puts m }
      end
    end

    class Module
      attr_accessor :name
      attr_accessor :version
      attr_accessor :source

      def initialize(name, version, options)
        @name    = name
        @version = version || '>= 0'
        @source  = options['source']
      end

      def to_s
        "#{name}: #{version} (#{source})"
      end

      def ==(other_mod)
        other_mod.name    == @name &&
        other_mod.version == @version &&
        other_mod.source  == @source
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
        options = Hash === args.last ? args.pop : {}
        version = args.first || '>= 0'

        _normalize_options(options)

        mod = Module.new(name, version, options)

        if current = @modules.find { |m| m.name == mod.name } and current != mod
          abort "You can't include a module twice with different versions or source\nYou included: #{current} and #{mod}."
        end
        @modules << mod
      end

      def _normalize_options(options)
        options.each_pair do |k, v|
          next if k === String
          options.delete(k)
          options[k.to_s] = v
        end

        invalid_keys = options.keys - %w() #%w(git branch ref tag)
        if invalid_keys.any?
          abort "You passed #{invalid_keys.join(", ")} as optiond for module #{name}"
        end

        options["source"] ||= @source
      end
    end
  end
end

