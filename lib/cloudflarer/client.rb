require 'faraday'
require 'json'
require 'hipsterhash'

module Cloudflarer
  class Client
    API_VERSION = 'v4'.freeze
    HOST = 'api.cloudflare.com'.freeze
    PATH = "/client/#{API_VERSION}".freeze
    URL = "https://#{HOST}#{PATH}".freeze

    def initialize(api_key: nil, email: nil)
      api_key ||= ENV['CLOUDFLARE_API_KEY']
      raise ArgumentError, "API Key is required." unless api_key
      email ||= ENV['CLOUDFLARE_EMAIL']
      raise ArgumentError, "Email is required" unless email
      headers = { 
        'X-Auth-Key' => api_key,
        'X-Auth-Email' => email,
        'Content-Type': 'application/json'
      }
      @connection = Faraday.new(URL, headers: headers)
    end

    %i(get head delete options).each do |verb|
      define_method verb do |path|
        respond { @connection.public_send(verb, path) }
      end
    end

    %i(put post patch).each do |verb|
      define_method verb do |path, data={}|
        respond { @connection.public_send(verb, path, data.to_json) }
      end
    end

    private

    def respond(&block)
      JSON.parse(yield.body)
    end

    Error = Class.new(Exception)
  end
end
