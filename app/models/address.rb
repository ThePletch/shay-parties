class Address < ApplicationRecord
  has_many :events

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

  def ==(other_address)
    %I[street street2 city state zip_code].all? do |address_attr|
      self.send(address_attr) == other_address.send(address_attr)
    end
  end
end
