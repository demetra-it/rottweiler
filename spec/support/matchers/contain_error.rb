# frozen_string_literal: true

RSpec::Matchers.define :contain_error do |error_type|
  match do |actual|
    actual.detect { |e| e[error_type] }.present?
  end

  failure_message do |_actual|
    "expected to contain #{error_type.inspect} error, but no #{error_type.inspect} error found"
  end

  failure_message_when_negated do |_actual|
    detected = actual.detect { |e| e[error_type] }
    "expected not to cointain #{error_type.inspect}, but #{detected.inspect} found"
  end
end
