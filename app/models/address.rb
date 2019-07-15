class Address < ApplicationRecord
  has_many :events

  # temporary shim to let us do the migration in place
  def event
    if self.respond_to?(:event_id)
      Event.find(self.event_id)
    else
      events.first
    end
  end

  def to_s
    [first_line, second_line].join("\n")
  end

  def first_line
    [street, street2].select(&:present?).join(", ")
  end

  def second_line
    city_state = [city, state].select(&:present?).join(", ")

    [city_state, zip_code].select(&:present?).join(" ")
  end
end
