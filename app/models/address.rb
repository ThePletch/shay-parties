class Address < ApplicationRecord
  belongs_to :event

  def first_line
    "#{street}, #{street2}"
  end

  def second_line
    "#{city}, #{state} #{zip_code}"
  end
end
