# frozen_string_literal: true

require 'test_helper'

describe Cloudflarer::CLI do
  it 'reads the environment' do
    env = Struct.new(:api_key, :email).new('abc123', 'alice@example.com')
    cli = Cloudflarer::CLI.new(env)
    _(cli.api_key).must_equal 'abc123'
    _(cli.email).must_equal 'alice@example.com'
  end
end

describe 'Cloudflarer::CLI#parse' do
  let(:cli) { Cloudflarer::CLI.new({}) }

  it 'parses options' do
    cli.parse %w[-e foo@bar.net -k 123abc]
    _(cli.email).must_equal('foo@bar.net')
    _(cli.api_key).must_equal('123abc')
    cli.parse %w[--email baz@bar.net]
    _(cli.email).must_equal('baz@bar.net')
  end
end

describe 'Cloudflarer::CLI#commands' do
  let(:commands) { Cloudflarer::CLI.new({}).send(:commands) }

  it 'contains the necessary commands' do
    _(commands['zones']).must_be_kind_of(Cloudflarer::CLI::Zones)
    _(commands['zone']).must_be_kind_of(Cloudflarer::CLI::Zone)
    _(commands['records']).must_be_kind_of(Cloudflarer::CLI::Records)
    _(commands['record']).must_be_kind_of(Cloudflarer::CLI::Record)
    _(commands[nil]).must_be_kind_of(Cloudflarer::CLI::NoCommand)
    _(commands['blah']).must_be_kind_of(Cloudflarer::CLI::UnknownCommand)
  end
end
