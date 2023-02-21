# frozen_string_literal: true

RSpec::Matchers.define :contain_error do |error_type|
  match do |actual|
    actual['errors'].detect { |e| e[error_type] }.present?
  end

  failure_message do |_actual|
    "expected to contain #{error_type.inspect} error, but none found"
  end

  failure_message_when_negated do |_actual|
    detected = actual.json_body['errors'].detect { |e| e[error_type] }
    "expected not to cointain #{error_type.inspect}, but #{detected.inspect} found"
  end
end
