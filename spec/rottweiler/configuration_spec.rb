# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.describe Rottweiler::Configuration do
  subject { described_class }

  it 'should exist' do
    expect(subject).to be_a(Class)
  end

  describe 'instance' do
    subject { described_class.new }

    it 'should allow to configure token header' do
      expect(subject).to respond_to(:token_header=)
      expect(subject).to respond_to(:token_header)

      subject.token_header = 'X-Auth-Token'
      expect(subject.token_header).to eq('X-Auth-Token')
    end

    it 'default token header should be Authorization' do
      expect(subject.token_header).to eq('Authorization')
    end

    it 'should allow to configure token param' do
      expect(subject).to respond_to(:token_param=)
      expect(subject).to respond_to(:token_param)

      subject.token_param = [:auth_token]
      expect(subject.token_param).to eq([:auth_token])
    end

    it 'default token param should be [:token]' do
      expect(subject.token_param).to eq([:token])
    end

    it 'should allow to configure response status' do
      expect(subject).to respond_to(:unauthorized_status=)
      expect(subject).to respond_to(:unauthorized_status)

      subject.unauthorized_status = :forbidden
      expect(subject.unauthorized_status).to eq(:forbidden)
    end

    it 'default unauthorized status should be :unauthorized' do
      expect(subject.unauthorized_status).to eq(:unauthorized)
    end

    it 'should allow to configure JWT' do
      expect(subject).to respond_to(:jwt)
      expect(subject.jwt).to be_a(Rottweiler::Configs::JWT)
    end
  end
end
# rubocop:enable Metrics/BlockLength
