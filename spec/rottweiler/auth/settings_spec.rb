# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.describe Rottweiler::Auth::Settings do
  subject { described_class }

  it 'should be defined' do
    expect(defined?(described_class)).not_to be_nil
    expect(described_class).to be_a(Class)
  end

  describe 'instance' do
    subject { described_class.new(ActionController::API) }

    it { is_expected.to respond_to(:reset!) }
    it { is_expected.to respond_to(:reset_skip!) }
    it { is_expected.to respond_to(:skip_authentication!) }
    it { is_expected.to respond_to(:skip_authentication?) }
    it { is_expected.to respond_to(:auth_failed_cbk) }
    it { is_expected.to respond_to(:auth_failed_cbk=) }
    it { is_expected.to respond_to(:auth_success_cbk) }
    it { is_expected.to respond_to(:auth_success_cbk=) }
    it { is_expected.to respond_to(:authenticate) }

    describe '#reset!' do
      it 'should reset all settings' do
        subject.auth_failed_cbk = -> { 'unauthorized' }
        subject.auth_success_cbk = -> { 'success' }
        subject.skip_authentication!(only: :index)

        subject.reset!

        expect(subject.auth_failed_cbk).to be_nil
        expect(subject.auth_success_cbk).to be_nil
        expect(subject.skip_authentication?(:index)).to be_falsey
        expect(subject.instance_variable_get('@skip')).to eq({ only: [], except: [], all: false })
      end
    end

    describe '#reset_skip!' do
      it 'should reset skip authentication settings' do
        subject.skip_authentication!(only: :index)
        expect(subject.instance_variable_get('@skip')).not_to eq({ only: [], except: [], all: false })

        subject.reset_skip!

        expect(subject.instance_variable_get('@skip')).to eq({ only: [], except: [], all: false })
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

      it 'should not accept :all option' do
        expect { subject.skip_authentication!(all: true) }.to raise_error(ArgumentError)
      end

      it 'should modify @skip instance variable' do
        subject.skip_authentication!(only: :index)
        expect(subject.instance_variable_get('@skip')).to eq({ only: [:index], except: [], all: false })

        subject.skip_authentication!(except: :index)
        expect(subject.instance_variable_get('@skip')).to eq({ only: [], except: [:index], all: true })
      end
    end

    describe '#auth_failed_cbk' do
      it 'should return nil by default' do
        expect(subject.auth_failed_cbk).to be_nil
      end

      it 'should return a Proc' do
        subject.auth_failed_cbk = -> { 'unauthorized' }
        expect(subject.auth_failed_cbk).to be_a(Proc)
      end

      context 'when set on parent but not on child' do
        let(:parent_controller) { Class.new(ActionController::API) { include Rottweiler::Authentication } }
        let(:controller) { Class.new(parent_controller) }
        let(:auth_failed_cbk) { -> { 'unauthorized' } }
        subject { described_class.new(parent_controller) }

        before do
          parent_controller.rottweiler.auth_failed_cbk = auth_failed_cbk
        end

        it 'should return the parent callback' do
          expect(subject.auth_failed_cbk).to be_a(Proc)
          expect(subject.auth_failed_cbk).to eq(auth_failed_cbk)
          expect(subject.auth_failed_cbk).to eq(parent_controller.rottweiler.auth_failed_cbk)
        end
      end
    end

    describe '#auth_success_cbk' do
      it 'should return nil by default' do
        expect(subject.auth_success_cbk).to be_nil
      end

      it 'should return a Proc' do
        subject.auth_success_cbk = -> { 'success' }
        expect(subject.auth_success_cbk).to be_a(Proc)
      end

      context 'when set on parent but not on child' do
        let(:parent_controller) { Class.new(ActionController::API) { include Rottweiler::Authentication } }
        let(:controller) { Class.new(parent_controller) }
        let(:auth_success_cbk) { -> { 'success' } }
        subject { described_class.new(parent_controller) }

        before do
          parent_controller.rottweiler.auth_success_cbk = auth_success_cbk
        end

        it 'should return the parent callback' do
          expect(subject.auth_success_cbk).to be_a(Proc)
          expect(subject.auth_success_cbk).to eq(auth_success_cbk)
          expect(subject.auth_success_cbk).to eq(parent_controller.rottweiler.auth_success_cbk)
        end
      end
    end

    describe '#authenticate' do
      let(:request) { double('request') }
      let(:jwt) { JwtHelper.encode({ id: 1, role: 'admin' }) }
      let(:headers) { { 'Authorization' => "Bearer #{jwt}" } }
      let(:params) { {} }
      let(:result) { subject.authenticate(request) }

      before do
        Rottweiler.config.jwt.decode_key = JwtHelper.public_rsa_key
        allow(request).to receive(:headers).and_return(headers)
        allow(request).to receive(:params).and_return(params)
      end

      it 'should accept a request as argument' do
        expect { subject.authenticate(request) }.not_to raise_error
      end

      it 'should return Rotteiler::Auth::Result' do
        expect(result).to be_a(Rottweiler::Auth::Result)
      end

      describe 'result when jwt is valid' do
        it 'should return a success result' do
          expect(result.valid?).to be_truthy
        end

        it 'should return the decoded jwt payload' do
          expect(result.data).to eq(JwtHelper.decode(jwt))
        end
      end

      describe 'result when jwt is expired' do
        let(:jwt) { JwtHelper.encode({ id: 1, role: 'admin' }, ttl: -1) }

        it 'should classify result as invalid' do
          expect(result.valid?).to be_falsey
        end

        it 'should contain :token_expired error' do
          expect(result.errors).to contain_error(:token_expired)
        end

        it 'should have nil data' do
          expect(result.data).to be_nil
        end
      end

      describe 'result when jwt is invalid' do
        let(:jwt) { 'invalid' }

        it 'should classify result as invalid' do
          expect(result.valid?).to be_falsey
        end

        it 'should contain :invalid_token_format error' do
          expect(result.errors).to contain_error(:invalid_token_format)
        end

        it 'should have nil data' do
          expect(result.data).to be_nil
        end
      end

      describe 'result when jwt has invalid algorithm' do
        let(:jwt) { JWT.encode({ id: 1, role: 'admin' }, JwtHelper.private_rsa_key, 'RS512') }

        it 'should classify result as invalid' do
          expect(result.valid?).to be_falsey
        end

        it 'should contain :invalid_token_algorithm error' do
          expect(result.errors).to contain_error(:invalid_token_algorithm)
        end

        it 'should have nil data' do
          expect(result.data).to be_nil
        end
      end

      describe 'result when jwt has invalid signature' do
        let(:key) { OpenSSL::PKey::RSA.new(2048) }
        let(:jwt) { JWT.encode({ id: 1, role: 'admin' }, key, 'RS256') }

        it 'should classify result as invalid' do
          expect(result.valid?).to be_falsey
        end

        it 'should contain :invalid_token_signature error' do
          expect(result.errors).to contain_error(:invalid_token_signature)
        end

        it 'should have nil data' do
          expect(result.data).to be_nil
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
