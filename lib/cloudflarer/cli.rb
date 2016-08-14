require 'ordu'
require 'cloudflarer'
require 'yaml'
require 'mustache'

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
    option('-q', '--[no-]quiet', 'print less information') do |q|
      $quiet = q
    end
    option('-D', '--[no-]debug', 'print lots of internal info') do |d|
      $debug = d
    end
    option('-V', '--version', 'show the version number') do |v|
      puts "Cloudflarer v#{Cloudflarer::VERSION}"
      puts "Cloudflare API version #{Cloudflarer::API_VERSION}"
      exit
    end
    option('-f', '--format FMT', 'specify output format') { |f| template(f) }
    command 'user', 'manage your user' do
      command 'update', 'change user properties' do
        option('--first_name NAME', 'First name') { |v| set(first_name: v) }
        option('--last_name NAME', 'Last name') { |v| set(last_name: v) }
        option('--telephone PHONE', 'Telephone') { |v| set(telephone: v) }
        option('--country ISO', 'Country') { |v| set(country: v) }
        option('--zipcode ZIP', 'Zipcode') { |v| set(zipcode: v) }
        action { update('user') }
      end

      action { show('user') }
    end

    command 'zones', 'manage your zones' do
      command 'show', 'show a zone' do
        action do |*ids|
          die("You need to specify the zone ID") if ids.empty?
          ids.each { |z| show("zones/#{z}") }
        end
      end
      command 'create', 'create a zone' do
        option('--[no-]jump_start', 'auto-fetch DNS records') do |j|
          set(:jump_start, j)
        end
        option('--name DOMAIN', 'domain name') { |v| set(name: v) }
        action { |name| post('zones' ) }
      end
      action { list('zones') }
    end

    command 'records', 'manage DNS records' do
      option('-z', '--zone ID', 'specify the zone') { |z| set(zone: z) }
      command 'show', 'show a DNS record' do
        action do |*ids|
          die("You need to specify the record ID") if ids.empty?
          template('{{id}} {{type}} {{name}} {{content}}')
          zone { |z| ids.each { |r| show("zones/#{z}/dns_records/#{r}") } }
        end
      end
      command 'create', 'create a new DNS record' do
        option('-z', '--zone ID', 'specify the zone') { |z| set(zone: z) }
        option('--type TYPE', 'DNS record type') { |v| set(type: v) }
        option('--name NAME', 'DNS record name') { |v| set(name: v) }
        option('--content ADDR', 'DNS record content') { |v| set(content: v) }
        action do
          zone { |z| create("zones/#{z}/dns_records") }
        end
      end
      command 'delete', 'delete a DNS record' do
        option('-z', '--zone ID', 'specify the zone') { |z| set(zone: z) }
        action do |*ids|
          die('You need to specify te record ID') if ids.empty?
          zone { |z| ids.each { |r| destroy("zones/#{z}/dns_records/#{r}") } }
        end
      end

      action do
        template('{{id}} {{type}} {{name}} {{content}}')
        zone { |z| show("zones/#{z}/dns_records") }
      end
    end

    # Yields the zone popped from the params, or dies
    def zone(&block)
      @zone ||= params.delete(:zone)
      die('You need to specify the zone (-z)') unless @zone
      yield @zone
    end

    # A place to gather params for queries
    def params
      @params ||= {}
    end

    # Sets a param for a query (used by options)
    def set(params = {})
      self.params.merge!(params)
    end

    # Creates a record (using params)
    def create(path)
      output { post(path, params) }
    end

    # Updates a record (using params)
    def update(path)
      output { patch(path, params) }
    end

    # Gets and shows a single resource
    def show(path)
      output { get(path) }
    end

    # Deletes and shows a resource
    def destroy(path)
      output { delete(path) }
    end
      
    # Gets and lists multiple resources
    def list(path)
      output { get(path) }
    end

    # Gets a resource
    def get(path)
      time("GET #{path}") { Cloudflarer.new.get(path) }
    end

    # Updates a resource (using params)
    def patch(path, params)
      time("PATCH #{path}") { Cloudflarer.new.patch(path, params) }
    end

    # Creates a resource (using params)
    def post(path, params)
      time("POST #{path}") { Cloudflarer.new.post(path, params) }
    end

    # Destroys a resource
    def delete(path)
      time("DELETE #{path}") { Cloudflarer.new.delete(path) }
    end

    # Times the block, which should return something with a status
    def time(msg, &block)
      return(yield) unless $verbose
      print "#{msg}..."
      t = Time.now.to_f
      response = yield
      print "(%0.2f ms) " % (Time.now.to_f - t)
      if info = response['result_info']
        print "[%s/%s/%s/%s] " %
          info.values_at(*%w(page per_page count total_count)).map(&:to_s)
      end
      puts "OK" if response.fetch('success')
      puts "FAIL" unless response.fetch('success')
      response
    end

    # Gets the formatter
    def format(&block)
      object = yield
      return object if object.is_a?(String)
      return object.to_yaml if template == 'yaml'
      return object.to_json if template == 'json'
      return render(template, object) if template.is_a?(String)
      return tablualte { yield } if template.nil?
      raise "Invalid template: #{template}"
    end

    # Gets the template with which to present the object
    def template(template = nil)
      $template ||= template
      $template || '{{id}} {{name}}'
    end

    # Renders the given object through the Mustache template
    def render(template, object)
      return object.map { |o| render(template, o) } if object.is_a?(Array)
      Mustache.render(template, object)
    end

    # Filters results, if required. Currently doesn't do anything.
    def filter(&block)
      result = yield
      return result.map { |o| filter { o } } if result.is_a?(Array)
      result
    end

    # Outputs in the format requested
    def output(&block)
      response = yield
      if response.fetch('success')
        puts format { filter { response.fetch('result') } }
      else
        puts format { response.fetch('error') }
      end
    end

    # Print the result of the block, if $debug is on
    def debug(msg, &block)
      result = yield
      puts "-- #{msg} #{'-' * (74 - msg.length)}" if $debug
      result
    end

    # Print the message to STDERR and exit (non-zero)
    def die(msg, code = 1)
      STDERR.puts msg
      exit code
    end
  end
end

if __FILE__ == $0
  Cloudflarer::CLI.parse!(ARGV)
end
