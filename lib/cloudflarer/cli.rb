# frozen_string_literal: true

require 'ostruct'
require 'yaml'
require 'mustache'

module Cloudflarer
  # Command-line interface for Cloudflarer. Create an instance with some
  # default options, and call #run with the command-line arguments.
  class CLI < OptionParser
    attr_accessor :api_key, :email
    attr_reader :commands

    def initialize(env)
      env = OpenStruct.new(env) if env.instance_of?(Hash)
      self.api_key = env.api_key
      self.email = env.email
      super()
      on('-k', '--key KEY', 'CloudFlare API key', method(:api_key=))
      on('-e', '--email EMAIL', 'CloudFlare email address', method(:email=))
    end

    def run(args)
      commands[parse(args).shift].new(self).run(args)
    end

    def inspect
      "#{self.class.name}##{object_id}"
    end

    NoCommand = Class.new(self)

    UnknownCommand = Class.new(self)

    Zones = Class.new(self)

    Zone = Class.new(self) do
      attr_accessor :zone
    end

    Records = Class.new(self) do
      attr_accessor :zone
    end

    Record = Class.new(self) do
      attr_accessor :zone
    end

    class << self
      attr_accessor :commands
    end

    self.commands = Hash.new(UnknownCommand).merge(
      zones: Zones, zone: Zone, records: Records, record: Record
    )

    commands[:''] = NoCommand
  end
end

Cloudflarer::CLI.parse!(ARGV) if $PROGRAM_NAME == __FILE__
