# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.describe Rottweiler::Authentication do
  subject { described_class }

  it 'should be defined' do
    expect(defined?(described_class)).not_to be_nil
    expect(described_class).to be_a(Module)
  end

  context 'when included in a class' do
    subject { Class.new(ActionController::API) { include Rottweiler::Authentication } }

    describe 'child class' do
      it { is_expected.to respond_to(:rottweiler) }
      it { is_expected.to respond_to(:skip_authentication!) }
      it { is_expected.to respond_to(:on_authentication_success) }
      it { is_expected.to respond_to(:on_authentication_failed) }

      describe '#rottweiler' do
        it 'should return a Rottweiler::Auth::Settings instance' do
          expect(subject.rottweiler).to be_a(Rottweiler::Auth::Settings)
        end

        it 'should return the same instance on each call' do
          expect(subject.rottweiler).to eq(subject.rottweiler)
        end

        it 'each class should have a different instance' do
          klass1 = Class.new(ActionController::API) { include Rottweiler::Authentication }
          klass2 = Class.new(ActionController::API) { include Rottweiler::Authentication }

          expect(klass1.rottweiler).not_to eq(klass2.rottweiler)
        end

        it 'should not be inherited by child classes' do
          parent = Class.new(ActionController::API) { include Rottweiler::Authentication }
          child = Class.new(parent)

          expect(parent.rottweiler).not_to eq(child.rottweiler)
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

        it 'should accept a Symbol, String or Array as :only option value' do
          expect { subject.skip_authentication!(except: 1) }.to raise_error(Rottweiler::InvalidParamsError)
          expect { subject.skip_authentication!(except: {}) }.to raise_error(Rottweiler::InvalidParamsError)

          expect { subject.skip_authentication!(except: :index) }.not_to raise_error
          expect { subject.skip_authentication!(except: 'index') }.not_to raise_error
          expect { subject.skip_authentication!(except: %i[index show]) }.not_to raise_error
        end

        it 'should raise Rottweiler::InvalidParamsError if :only and :except options are both present' do
          expect do
            subject.skip_authentication!(only: :index, except: :show)
          end.to raise_error(Rottweiler::InvalidParamsError)
        end
      end

      describe '#on_authentication_success' do
        pending 'should accept a block as argument'
        pending 'should raise an error if no block is given'
        pending 'should be called on authentication success'
      end

      describe '#on_authentication_failed' do
        pending 'should accept a block as argument'
        pending 'should raise an error if no block is given'
        pending 'should be called on authentication failed'
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
