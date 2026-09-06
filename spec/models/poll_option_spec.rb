require 'rails_helper'

describe PollOption do
  it "requires a choice" do
    option = FactoryBot.build(:poll_option, choice: nil)
    expect(option).not_to be_valid
    expect(option.errors[:choice]).to be_present
  end
end
