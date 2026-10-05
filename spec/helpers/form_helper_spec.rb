# frozen_string_literal: true

require "rails_helper"

RSpec.describe FormHelper, type: :helper do
  describe "#dynamic_list" do
    it "wraps existing records, a row template, and an add button" do
      event = Event.new
      allow(helper).to receive(:render).and_return("<div class='templated-row'></div>".html_safe)

      html = helper.bootstrap_form_with(model: event, url: "/events") do |form|
        helper.dynamic_list(
          "Add poll",
          form,
          :polls,
          {partial: "polls/form", locals: {}, layout: :inline},
          class: "btn btn-success",
        ) { "existing-row".html_safe }
      end

      expect(html).to have_css("[data-controller='dynamic-list']")
      expect(html).to have_css("template[data-dynamic-list-target='template']", visible: :hidden)
      expect(html).to have_css("[data-dynamic-list-target='rows']", text: "existing-row")
      expect(html).to have_button("Add poll")
      expect(html).to have_css("[data-dynamic-list-child-index-value='new_polls']")
    end

    it "omits the add button when the label is blank" do
      event = Event.new
      allow(helper).to receive(:render).and_return("".html_safe)

      html = helper.bootstrap_form_with(model: event, url: "/events") do |form|
        helper.dynamic_list(nil, form, :polls, {partial: "polls/form", locals: {}})
      end

      expect(html).to have_css("[data-controller='dynamic-list']")
      expect(html).not_to have_css("[data-dynamic-list-target='addButton']")
    end
  end

  describe "#confirm_form" do
    it "asks for confirmation before the form submits" do
      form = helper.confirm_form("Delete this comment?", class: "d-inline")

      expect(form[:class]).to eq("d-inline")
      expect(form[:data][:controller]).to eq("confirm")
      expect(form[:data][:action]).to eq("submit->confirm#guard")
      expect(form[:data][:confirm_message_value]).to eq("Delete this comment?")
    end
  end
end
