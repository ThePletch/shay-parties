# frozen_string_literal: true

require "rails_helper"

RSpec.describe Webhooks::SesController, type: :controller do
  let(:payload) do
    {
      "Type" => "Notification",
      "Message" => { "eventType" => "Delivery" }.to_json,
    }.to_json
  end

  it "rejects invalid SNS signatures" do
    allow(Sns::Verifier).to receive(:authentic?).and_return(false)

    post :create, body: payload

    expect(response).to have_http_status(:forbidden)
  end

  it "accepts a signed notification" do
    allow(Sns::Verifier).to receive(:authentic?).and_return(true)
    allow(Ses::NotificationProcessor).to receive(:process)

    post :create, body: payload

    expect(response).to have_http_status(:ok)
    expect(Ses::NotificationProcessor).to have_received(:process)
  end
end
