# frozen_string_literal: true

require "rails_helper"

RSpec.describe StimulusHelper, type: :helper do
  describe "#stimulus_action" do
    it "builds a Stimulus action descriptor from its parts" do
      expect(helper.stimulus_action("click", "dynamic-list", "add")).to eq "click->dynamic-list#add"
    end
  end
end
