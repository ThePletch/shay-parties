module StimulusHelper
  def stimulus_action(event_name, controller_identifier, method_name)
    "#{event_name}->#{controller_identifier}##{method_name}"
  end
end
