require 'ordu'
require 'cloudflarer'

module Cloudflarer
  class CLI < Ordu
    option('-h', '--help', 'show this message') do
      puts to_s
      exit
    end
    option('-k', '--api-key API_KEY', 'specify the API key') do |key|
      CLOUDFLARE_API_KEY = key
    end
    option('-e', '--email EMAIL', 'specify the Cloudflare Email') do |email|
      CLOUDFLARE_EMAIL = email
    end
    option('-v', '--[no-]verbose', 'print request/response') do |v|
      $verbose = v
    end
    option('-D', '--[no-]debug', 'print lots of internal info') do |d|
      $debug = d
    end
    option('-V', '--version', 'show the version number') do |v|
      puts "cloudflarer v#{Cloudflarer::VERSION}"
      puts "API version #{Cloudflarer::API_VERSION}"
      exit
    end
    command 'user', 'manage your user' do
      command 'update', 'change user properties' do
        option('--first_name NAME', 'First name') { |v| set(first_name: v) }
        option('--last_name NAME', 'Last name') { |v| set(last_name: v) }
        option('--telephone PHONE', 'Telephone') { |v| set(telephone: v) }
        option('--country ISO', 'Country') { |v| set(country: v) }
        option('--zipcode ZIP', 'Zipcode') { |v| set(zipcode: v) }
        action { patch('user') }
      end

      command 'billing', 'see billing info' do
        command 'profile', 'see user billing profile' do
          action { get('user/billing/profile') }
        end
        command 'history', 'see user billing history' do
          action { get('user/billing/history') }
        end
        command 'subscriptions', 'see user billing subscriptions' do
          command 'apps', 'see user billing subscription apps' do
            command 'show', 'show a subscription' do
              option('--id ID', 'specify the app', REQUIRED) { |id| @id = id }
              action { get("user/billing/subscriptions/#{@id}") }
            end
            action { get('user/billing/subscriptions') }
          end
        end
      end

      action { get('user') }
    end

    def params
      @params ||= {}
    end

    def set(params = {})
      puts "Setting #{params} (#{self.params})" if $debug
      self.params.merge!(params)
    end

    def get(path)
      puts "GET #{path}" if $verbose
      output { Cloudflarer.new.get(path) }
    end

    def patch(path)
      puts "PATCH #{path} (#{params})" if $verbose
      output { Cloudflarer.new.patch(path, params) }
    end

    def post(path)
      puts "POST #{path} (#{params})" if $verbose
      output { Cloudflarer.new.patch(path, params) }
    end

    def output(&block)
      # TODO: better formatting
      result = yield.result
      puts("#{'-' * 80}\n#{result.inspect}\n#{'-' * 80}") if $debug
      width = result.keys.map(&:length).max + 1
      format = "%-#{width}s %s"
      result.each do |k, v|
        puts(format % [k, v])
      end
    end
  end
end

if __FILE__ == $0
  Cloudflarer::CLI.parse!(ARGV)
end
