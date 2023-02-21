# frozen_string_literal: true

module Examples
  class ConfigurationController < ActionController::API
    include Rottweiler::Authentication
  end
end

# rubocop:disable Metrics/BlockLength
RSpec.describe Examples::ConfigurationController, type: :controller do
  subject { described_class }
  include_context 'controller setup for specs'

  before do
    Rottweiler::Configuration.reset!
    Rottweiler.config.jwt.decode_key = JwtHelper.public_rsa_key
  end

  describe 'configuration' do
    describe 'token_header' do

      it 'should be used to identify the header containing the jwt token' do
        Rottweiler.config.token_header = 'X-Auth-Token'
        jwt = JwtHelper.encode({ id: 1, role: 'admin' })

        request.headers['Authorization'] = "Bearer #{jwt}"
        response = get(action_name)
        expect(response.status).to eq(401)

        request.headers['X-Auth-Token'] = "Bearer #{jwt}"
        response = get(action_name)
        expect(response.status).to eq(200)
      end

      it 'by default should be "Authorization"' do
        expect(Rottweiler::Configuration.new.token_header).to eq('Authorization')
      end

      it 'should be configurable using a block' do
        Rottweiler.config do |config|
          config.token_header = 'X-My-Auth-Token'
        end

        expect(Rottweiler.config.token_header).to eq('X-My-Auth-Token')
      end
    end

    describe 'token_param' do
      it 'by default should be "token"' do
        expect(Rottweiler::Configuration.new.token_param).to eq(%i[token])
      end

      it 'should be used to identify the param containing the jwt token' do
        jwt = JwtHelper.encode({ id: 1, role: 'admin' })

        # Test with default configuration, which gets token value from `params[:token]`.
        Rottweiler.config.token_param = %i[token]
        response = get(action_name, params: { token: jwt })
        expect(response.status).to eq(200)

        response = get(action_name, params: { param1: jwt })
        expect(response.status).to eq(401)

        # Test with configuration that gets token value from `params[:jwt][:token]`.
        Rottweiler.config.token_param = %i[jwt token]
        response = get(action_name, params: { token: jwt })
        expect(response.status).to eq(401)

        response = get(action_name, params: { jwt: { token: jwt } })
        expect(response.status).to eq(200)
      end

      it 'should be configurable using a block' do
        Rottweiler.config do |config|
          config.token_param = %i[custom param]
        end
      end
    end

    describe 'jwt' do
      it 'should be an instance of Rottweiler::Configs::JWT' do
        expect(Rottweiler.config.jwt).to be_a(Rottweiler::Configs::JWT)
      end

      it 'should allow to configure the algorithm to use for JWT verification' do
        Rottweiler.config.jwt.algorithm = 'HS256'
        expect(Rottweiler.config.jwt.algorithm).to eq('HS256')
      end

      it 'should raise Rottweiler::InvalidJwtAlgorithmError if algorithm is not available' do
        expect { Rottweiler.config.jwt.algorithm = 'invalid' }.to raise_error(Rottweiler::InvalidJwtAlgorithmError)
      end

      it 'should allow to configure the decode key to use for JWT verification' do
        jwt_key = 'my secret key'
        jwt_algorithm = 'HS256'
        payload = { id: 1, role: 'admin' }

        # Before configuration change, JWT verification should fail.
        response = get(action_name)
        expect(response.status).to eq(401)

        Rottweiler.config do |config|
          config.jwt.algorithm = jwt_algorithm
          config.jwt.decode_key = jwt_key
        end

        jwt = JWT.encode(payload.to_json, jwt_key, jwt_algorithm)
        request.headers['Authorization'] = "Bearer #{jwt}"

        # After configuration change, JWT verification should succeed.
        response = get(action_name)
        expect(response.status).to eq(200)
      end

      context 'when decode key is not configured' do
        before do
          Rottweiler.config.jwt.decode_key = nil
        end

        it 'should respond with 401 code' do
          response = get(action_name)
          expect(response.status).to eq(401)
        end
      end

      context 'when decode key has invalid format' do
        before do
          Rottweiler.config.jwt.decode_key = 'invalid'
          request.headers['Authorization'] = "Bearer #{JwtHelper.encode({ id: 1, role: 'admin' })}"
        end

        it 'should respond with 401 code' do
          response = get(action_name)
          expect(response.status).to eq(401)
          expect(json_body).to contain_error(:jwt_verification_error)
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
