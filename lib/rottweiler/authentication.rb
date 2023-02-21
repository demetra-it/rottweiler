# frozen_string_literal: true

require 'active_support/concern'
require_relative 'auth/settings'

module Rottweiler
  # Implements the logic for requests authentication in Rails controllers.
  module Authentication
    extend ActiveSupport::Concern

    included do
      before_action do
        next if rottweiler.skip_authentication?(action_name)

        authentication = rottweiler.authenticate(request)
        if authentication.valid?
          rottweiler_on_authentication_success!(authentication.result)
        else
          rottweiler_on_authentication_failed!(authentication.errors)
          force_rottweiler_auth_failure_status!
        end
      end
    end

    # Implement Rottweiler::Authentication class methods
    module ClassMethods
      attr_accessor :_rottweiler

      def rottweiler
        self._rottweiler ||= Rottweiler::Auth::Settings.new(superclass)
      end

      def skip_authentication!(**options)
        rottweiler.skip_authentication!(**options)
      end

      def on_authentication_success(method_name = nil, &callback)
        rottweiler.auth_success_cbk = callback || method_name
      end

      def on_authentication_failed(method_name = nil, &callback)
        rottweiler.auth_failed_cbk = callback || method_name
      end
    end

    protected

    def rottweiler
      self.class.rottweiler
    end

    def rottweiler_on_authentication_success!(data)
      return if rottweiler.auth_success_cbk.nil?

      if rottweiler.auth_success_cbk.is_a?(Proc)
        instance_exec(data, &rottweiler.auth_success_cbk)
      else
        send(rottweiler.auth_success_cbk, data)
      end
    end

    def rottweiler_on_authentication_failed!(errors)
      if rottweiler.auth_failed_cbk.is_a?(Proc)
        instance_exec(errors, &rottweiler.auth_failed_cbk)
      elsif rottweiler.auth_failed_cbk
        send(rottweiler.auth_failed_cbk, errors)
      else
        render json: { errors: errors }
      end
    end

    def force_rottweiler_auth_failure_status!
      response.status = Rottweiler.config.unauthorized_status
    end
  end
end
