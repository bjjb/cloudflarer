require 'test_helper'

describe Cloudflarer::Client do
  it 'is version 4' do
    Cloudflarer::Client::API_VERSION.must_equal('v4')
    Cloudflarer::Client::PATH.must_equal('/client/v4')
    Cloudflarer::Client::URL.must_equal('https://api.cloudflare.com/client/v4')
  end

  describe '::new' do
    creds = {}

    before do
      creds[:key] = ENV['CLOUDFLARE_API_KEY']
      creds[:email] = ENV['CLOUDFLARE_EMAIL']
      ENV['CLOUDFLARE_API_KEY'] = nil
      ENV['CLOUDFLARE_EMAIL'] = nil
    end

    after do
      ENV['CLOUDFLARE_API_KEY'] = creds[:key]
      ENV['CLOUDFLARE_EMAIL'] = creds[:email]
    end

    it 'complains if missing the api key' do
      lambda {
        Cloudflarer::Client.new(email: 'test@example.com')
      }.must_raise(ArgumentError)
    end

    it 'complains if missing the email' do
      lambda {
        Cloudflarer::Client.new(api_key: 'abc123')
      }.must_raise(ArgumentError)
    end

    it 'can get the api key from the CLOUDFLARE_API_KEY env var' do
      ENV['CLOUDFLARE_API_KEY'] = 'abc123'
      Cloudflarer::Client.new(email: 'test@example.com')
    end

    it 'can get the email from the CLOUDFLARE_EMAIL env var' do
      ENV['CLOUDFLARE_EMAIL'] = 'test@example.com'
      Cloudflarer::Client.new(api_key: 'abc123')
    end
  end

  %w(put post patch).each do |m|
    client = Cloudflarer::Client.new
    mock = Minitest::Mock.new
    resp = Struct.new(:body)
    client.instance_eval { instance_variable_set(:'@connection', mock) }
    describe "##{m}" do
      mock.expect(:"#{m}", resp.new('{}'), ['/my/path', '{}'])
      it "makes a #{m.upcase} request" do
        client.public_send(:"#{m}", '/my/path', {})
        mock.verify
      end
    end
  end

  %w(get head delete options).each do |m|
    client = Cloudflarer::Client.new
    mock = Minitest::Mock.new
    resp = Struct.new(:body)
    client.instance_eval { instance_variable_set(:'@connection', mock) }
    describe "##{m}" do
      mock.expect(:"#{m}", resp.new('{}'), ['/my/path'])
      it "makes a #{m.upcase} request" do
        client.public_send(:"#{m}", '/my/path')
        mock.verify
      end
    end
  end
end
