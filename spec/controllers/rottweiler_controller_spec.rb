# frozen_string_literal: true

module Examples
  class RottweilerController < ActionController::API
    include Rottweiler::Authentication
  end
end

# rubocop:disable Metrics/BlockLength
RSpec.describe Examples::RottweilerController, type: :controller do
  subject { described_class }
  include_context 'controller setup for specs'

  it { is_expected.to respond_to(:rottweiler) }
  it { is_expected.to respond_to(:skip_authentication!) }
  it { is_expected.to respond_to(:on_authentication_success) }
  it { is_expected.to respond_to(:on_authentication_failed) }

  describe '#rottweiler' do
    it 'should return an instance of Rottweiler::Auth::Settings' do
      expect(subject.rottweiler).to be_a(Rottweiler::Auth::Settings)
    end

    it 'should return the same instance on each call' do
      expect(subject.rottweiler).to eq(subject.rottweiler)
    end
  end

  describe '#skip_authentication!' do
    it 'should accept :only option' do
      expect { subject.skip_authentication!(only: :index) }.not_to raise_error
    end

    it 'should accept :except option' do
      expect { subject.skip_authentication!(except: :index) }.not_to raise_error
    end

    it 'should accept a Symbol, String or Array as :only option value' do
      expect { subject.skip_authentication!(only: 1) }.to raise_error(Rottweiler::InvalidParamsError)
      expect { subject.skip_authentication!(only: {}) }.to raise_error(Rottweiler::InvalidParamsError)

      expect { subject.skip_authentication!(only: :index) }.not_to raise_error
      expect { subject.skip_authentication!(only: 'index') }.not_to raise_error
      expect { subject.skip_authentication!(only: %i[index show]) }.not_to raise_error
    end

    it 'should accept a Symbol, String or Array as :except option value' do
      expect { subject.skip_authentication!(except: 1) }.to raise_error(Rottweiler::InvalidParamsError)
      expect { subject.skip_authentication!(except: {}) }.to raise_error(Rottweiler::InvalidParamsError)

      expect { subject.skip_authentication!(except: :index) }.not_to raise_error
      expect { subject.skip_authentication!(except: 'index') }.not_to raise_error
      expect { subject.skip_authentication!(except: %i[index show]) }.not_to raise_error
    end

    it 'should raise an error if :only and :except options are both present' do
      expect { subject.skip_authentication!(only: :index, except: :show) }.to raise_error(Rottweiler::InvalidParamsError)
    end

    it 'should skip authentication for the actions specified in :only option' do
      subject.skip_authentication!(only: action_name)
      response = get action_name
      expect(response.status).to eq(200)
    end

    it 'should skip authentication for all actions if :only option is not present' do
      subject.skip_authentication!
      response = get action_name
      expect(response.status).to eq(200)
    end

    it 'should not skip authentication for actions specified in :except option' do
      subject.skip_authentication!(except: action_name)
      response = get action_name
      expect(response.status).to eq(401)
    end
  end

  describe '#on_authentication_success' do
    it 'should accept a block' do
      expect { subject.on_authentication_success { true } }.not_to raise_error
    end

    it 'should accept a Symbol or a String as a method name' do
      expect { subject.on_authentication_success(:test) }.not_to raise_error
      expect { subject.on_authentication_success('test') }.not_to raise_error
    end

    shared_examples '#on_authentication_success: should be called' do
      it 'should call the block' do
        # Setup a success callback, which will set `block_called` to `true`, so that
        # we can verify that the block has been called.
        block_called = false
        subject.on_authentication_success { block_called = true }

        response = get(action_name)

        expect(response.status).to eq(200)
        expect(block_called).to eq(true)
      end

      it 'should call the specified method' do
        # Generate a random method name and use it to mockup a method on the controller,
        # so that we can verify that the method has been called.
        method_name = SecureRandom.hex(64)
        subject.on_authentication_success(method_name)
        allow(controller).to receive(method_name).and_return(true)

        response = get(action_name)

        expect(response.status).to eq(200)
        expect(controller).to have_received(method_name).at_least(:once)
      end
    end

    shared_examples '#on_authentication_success: should not be called' do |status_code = 401|
      it 'should not call the block' do
        # Setup a success callback, which will set `block_called` to `true`, so that
        # we can verify that the block has been called.
        block_called = false
        subject.on_authentication_success { block_called = true }

        response = get(action_name)

        expect(response.status).to eq(status_code)
        expect(block_called).to eq(false)
      end

      it 'should not call the specified method' do
        # Generate a random method name and use it to mockup a method on the controller,
        # so that we can verify that the method has been called.
        method_name = SecureRandom.hex(64)
        subject.on_authentication_success(method_name)
        allow(controller).to receive(method_name).and_return(true)

        response = get(action_name)

        expect(response.status).to eq(status_code)
        expect(controller).not_to have_received(method_name)
      end
    end

    context 'when jwt token is valid' do
      let(:jwt_payload) { { id: (rand * 100).to_i, role: %w[admin pm user].sample } }
      let!(:jwt) { JwtHelper.encode(jwt_payload) }

      before do
        request.headers['Authorization'] = "Bearer #{jwt}"
      end

      include_examples '#on_authentication_success: should be called'
    end

    context 'when jwt token is invalid' do
      before do
        request.headers['Authorization'] = 'Bearer invalid_token'
      end

      include_examples '#on_authentication_success: should not be called'
    end

    context 'when action has been specified in :only option of #skip_authentication' do
      before do
        subject.skip_authentication!(only: action_name)
      end

      include_examples '#on_authentication_success: should not be called', 200
    end

    context 'when skip_authentication! with no arguments has been called' do
      before do
        subject.skip_authentication!
      end

      include_examples '#on_authentication_success: should not be called', 200
    end
  end

  describe '#on_authentication_failed' do
    it 'should accept a block' do
      expect { subject.on_authentication_failed { true } }.not_to raise_error
    end

    it 'should accept a Symbol or a String as a method name' do
      expect { subject.on_authentication_failed(:test) }.not_to raise_error
      expect { subject.on_authentication_failed('test') }.not_to raise_error
    end

    shared_examples '#on_authentication_failed: should be called' do
      it 'should call the block' do
        # Setup a success callback, which will set `block_called` to `true`, so that
        # we can verify that the block has been called.
        block_called = false
        subject.on_authentication_failed { block_called = true }

        response = get(action_name)

        expect(response.status).to eq(401)
        expect(block_called).to eq(true)
      end

      it 'should call the specified method' do
        # Generate a random method name and use it to mockup a method on the controller,
        # so that we can verify that the method has been called.
        method_name = SecureRandom.hex(64)
        subject.on_authentication_failed(method_name)
        allow(controller).to receive(method_name).and_return(true)

        response = get(action_name)

        expect(response.status).to eq(401)
        expect(controller).to have_received(method_name).at_least(:once)
      end

      it 'should pass the list of errors message to the block' do
        # Setup a success callback, which will set `block_called` to `true`, so that
        # we can verify that the block has been called.
        result_errors = nil
        subject.on_authentication_failed do |errors|
          result_errors = errors
        end

        response = get(action_name)

        expect(response.status).to eq(401)
        expect(result_errors).to be_a(Array)
      end
    end

    shared_examples '#on_authentication_failed: should not be called' do |status_code = 401|
      it 'should not call the block' do
        # Setup a success callback, which will set `block_called` to `true`, so that
        # we can verify that the block has been called.
        block_called = false
        subject.on_authentication_failed { block_called = true }

        response = get(action_name)

        expect(response.status).to eq(status_code)
        expect(block_called).to eq(false)
      end

      it 'should not call the specified method' do
        # Generate a random method name and use it to mockup a method on the controller,
        # so that we can verify that the method has been called.
        method_name = SecureRandom.hex(64)
        subject.on_authentication_failed(method_name)
        allow(controller).to receive(method_name).and_return(true)

        response = get(action_name)

        expect(response.status).to eq(status_code)
        expect(controller).not_to have_received(method_name)
      end
    end

    context 'when jwt token is valid' do
      let(:jwt_payload) { { id: (rand * 100).to_i, role: %w[admin pm user].sample } }
      let!(:jwt) { JwtHelper.encode(jwt_payload) }

      before do
        request.headers['Authorization'] = "Bearer #{jwt}"
      end

      include_examples '#on_authentication_failed: should not be called', 200
    end

    context 'when jwt token is invalid' do
      before do
        request.headers['Authorization'] = 'Bearer invalid_token'
      end

      include_examples '#on_authentication_failed: should be called'
    end

    context 'when action has been specified in :only option of #skip_authentication' do
      before do
        subject.skip_authentication!(only: action_name)
      end

      include_examples '#on_authentication_failed: should not be called', 200
    end

    context 'when skip_authentication! has been called' do
      before do
        subject.skip_authentication!
      end

      include_examples '#on_authentication_failed: should not be called', 200
    end
  end

  describe 'Request verification' do
    let(:payload) { { id: 1, role: 'admin' } }
    let(:jwt) { JwtHelper.encode(payload) }
    let(:params) { {} }

    context 'when no jwt token is present' do
      it 'should return 401' do
        response = get action_name
        expect(response.status).to eq(401)
      end
    end

    shared_examples 'Request verification: should fail' do
      it 'should respond with code 401' do
        response = get action_name, params: params
        expect(response.status).to eq(401)
      end

      it 'should call on_authentication_failed' do
        # Setup a success callback, which will set `block_called` to `true`, so that
        # we can verify that the block has been called.
        block_called = false
        subject.on_authentication_failed { block_called = true }

        response = get action_name, params: params

        expect(response.status).to eq(401)
        expect(block_called).to eq(true)
      end

      it 'should not call on_authentication_success' do
        # Setup a success callback, which will set `block_called` to `true`, so that
        # we can verify that the block has been called.
        block_called = false
        subject.on_authentication_success { block_called = true }

        response = get action_name, params: params

        expect(response.status).to eq(401)
        expect(block_called).to eq(false)
      end
    end

    shared_examples 'Request verification: should succeed' do
      it 'should respond with code 200' do
        response = get action_name, params: params
        expect(response.status).to eq(200)
      end

      it 'should call on_authentication_success' do
        # Setup a success callback, which will set `block_called` to `true`, so that
        # we can verify that the block has been called.
        block_called = false
        subject.on_authentication_success { block_called = true }

        response = get action_name, params: params

        expect(response.status).to eq(200)
        expect(block_called).to eq(true)
      end

      it 'should not call on_authentication_failed' do
        # Setup a success callback, which will set `block_called` to `true`, so that
        # we can verify that the block has been called.
        block_called = false
        subject.on_authentication_failed { block_called = true }

        response = get action_name, params: params

        expect(response.status).to eq(200)
        expect(block_called).to eq(false)
      end
    end

    shared_examples 'Request verification: existing JWT token examples' do
      context 'when jwt token is valid' do
        include_examples 'Request verification: should succeed'
      end

      context 'when jwt token is invalid' do
        let(:jwt) { 'invalid_token' }

        include_examples 'Request verification: should fail'
      end

      context 'when jwt token is expired' do
        let(:jwt) { JwtHelper.encode(payload, ttl: -1) }

        include_examples 'Request verification: should fail'
      end

      context 'when jwt token has invalid format' do
        let(:jwt) { JWT.encode(payload, 'mysecret', 'HS256') }

        include_examples 'Request verification: should fail'
      end
    end

    context 'when jwt token is present in headers' do
      before do
        request.headers['Authorization'] = "Bearer #{jwt}"
      end

      include_examples 'Request verification: existing JWT token examples'
    end

    context 'when jwt token is present in params' do
      let(:params) { { token: jwt } }

      include_examples 'Request verification: existing JWT token examples'
    end
  end
end
# rubocop:enable Metrics/BlockLength
