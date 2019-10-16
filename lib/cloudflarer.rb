# frozen_string_literal: true

# A library to help manage your Cloudflare domains and settings.
module Cloudflarer
  autoload :VERSION, 'cloudflarer/version'
  autoload :API_VERSION, 'cloudflarer/version'
  autoload :Client, 'cloudflarer/client'
  autoload :YAML, 'yaml'
  autoload :Pathname, 'pathname'
  autoload :CLI, 'cloudflarer/cli'

  def self.new(*args)
    Client.new(*args)
  end
end
