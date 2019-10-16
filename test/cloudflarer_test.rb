# frozen_string_literal: true

require 'test_helper'

describe Cloudflarer do
  it 'has a version number' do
    Cloudflarer::VERSION.wont_be_nil
  end

  it 'has a client' do
    Cloudflarer::Client.wont_be_nil
  end
end
