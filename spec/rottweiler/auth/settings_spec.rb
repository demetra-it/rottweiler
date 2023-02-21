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
      pending 'should accept a request as argument'
      pending 'should return Rotteiler::Auth::Result'
    end
  end
end
# rubocop:enable Metrics/BlockLength
