RSpec::Matchers.define :include_event do |expected_event_class|
  match do |actual_events|
    actual_events.any? do |actual_event|
      actual_event.is_a?(expected_event_class) && params_match?(actual_event)
    end
  end

  chain :with, :expected_params

  private

  def params_match?(actual_event)
    (expected_params || {}).all? do |key, expected_value|
      if actual_event.respond_to?(key)
        actual_event.public_send(key)
      else
        actual_event[key] == expected_value
      end
    end
  end
end
