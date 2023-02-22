# frozen_string_literal: true

RSpec.describe Rottweiler do
  it 'has a version number' do
    expect(Rottweiler::VERSION).not_to be nil
  end

  it 'has a configuration' do
    expect(Rottweiler).to respond_to(:config)
    expect(Rottweiler.config).to be_a(Rottweiler::Configuration)
  end

  describe '#config' do
    it 'should accept a block argument' do
      expect { |b| Rottweiler.config(&b) }.to yield_control
    end

    it 'should allow to change configuration with a block' do
      Rottweiler.config do |config|
        config.token_header = 'X-Auth-Token'
        config.jwt.algorithm = 'HS256'
      end

      expect(Rottweiler.config.token_header).to eq('X-Auth-Token')
      expect(Rottweiler.config.jwt.algorithm).to eq('HS256')
    end

    it 'should return a configuration when no block is given' do
      expect(Rottweiler.config).to be_a(Rottweiler::Configuration)
    end
  end
end
