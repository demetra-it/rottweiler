# frozen_string_literal: true

RSpec.shared_context 'controller setup for specs' do
  let(:action_name) { SecureRandom.hex(32).to_sym }

  before :all do
    Rottweiler.config.jwt.decode_key = JwtHelper.public_rsa_key
  end

  before :each do
    my_action = action_name
    my_controller = subject.name.underscore.gsub(/_controller$/, '')
    routes.draw do
      get my_action, to: "#{my_controller}##{my_action}"
    end

    subject.define_method action_name do
      render json: { message: 'ok' }
    end
  end

  after :each do
    subject.rottweiler.reset!
  end
end
