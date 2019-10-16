# frozen_string_literal: true

require 'faraday'
require 'json'

module Cloudflarer
  # A client for the CloudFlare HTTP REST API (v4)
  class Client
    API_VERSION = 'v4'
    HOST = 'api.cloudflare.com'
    PATH = "/client/#{API_VERSION}"
    URL = "https://#{HOST}#{PATH}"

    def initialize(api_key: nil, email: nil)
      api_key ||= ENV['CLOUDFLARE_API_KEY']
      raise ArgumentError, 'API Key is required.' unless api_key

      email ||= ENV['CLOUDFLARE_EMAIL']
      raise ArgumentError, 'Email is required' unless email

      headers = {
        'X-Auth-Key' => api_key,
        'X-Auth-Email' => email,
        'Content-Type': 'application/json'
      }
      @connection = Faraday.new(URL, headers: headers)
    end

    %i[get head delete options].each do |verb|
      define_method verb do |path|
        respond { @connection.public_send(verb, path) }
      end
    end

    %i[put post patch].each do |verb|
      define_method verb do |path, data = {}|
        respond { @connection.public_send(verb, path, data.to_json) }
      end
    end

    private

    def respond
      JSON.parse(yield.body)
    end
  end
end
