# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.describe Rottweiler::Configs::JWT do
  subject { described_class }

  it 'should be defined' do
    expect(defined?(described_class)).not_to be_nil
    expect(described_class).to be_a(Class)
  end

  describe 'instance' do
    subject { described_class.new }

    it 'should allow to set JWT algorithm to use' do
      expect(subject).to respond_to(:algorithm=)
      expect(subject).to respond_to(:algorithm)
      subject.algorithm = 'HS256'
      expect(subject.algorithm).to eq('HS256')
    end

    it 'default algorithm should be RS256' do
      expect(subject.algorithm).to eq('RS256')
    end

    it 'should allow to set decode key' do
      expect(subject).to respond_to(:decode_key=)
      expect(subject).to respond_to(:decode_key)

      subject.decode_key = 'secret'
      expect(subject.decode_key).to eq('secret')
    end

    it 'default decode key should be nil' do
      expect(subject.decode_key).to be_nil
    end
  end
end
# rubocop:enable Metrics/BlockLength
