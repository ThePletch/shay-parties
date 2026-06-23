# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActiveStorage::LambdaTransform do
  let(:blob) do
    ActiveStorage::Blob.create_and_upload!(
      io: file_fixture("test_image.png").open,
      filename: "test_image.png",
      content_type: "image/png"
    )
  end

  let(:transformations) do
    { resize: "1900", crop: "1900x500+0+0" }
  end

  before do
    stub_const("ENV", ENV.to_hash.merge(
      "ACTIVE_STORAGE_TRANSFORM_LAMBDA" => "test-image-transform",
      "ACTIVE_STORAGE_S3_REGION" => "us-east-2"
    ))
  end

  describe ".transform_via_lambda" do
    it "creates a variant record from the Lambda response" do
      lambda_client = instance_double(Aws::Lambda::Client)
      allow(Aws::Lambda::Client).to receive(:new)
        .with(region: "us-east-2", use_dualstack_endpoint: true)
        .and_return(lambda_client)
      allow(lambda_client).to receive(:invoke).and_return(
        instance_double(
          Aws::Lambda::Types::InvokeResponse,
          function_error: nil,
          payload: StringIO.new({
            statusCode: 200,
            body: Base64.strict_encode64(file_fixture("test_image.png").binread),
            contentType: "image/png"
          }.to_json)
        )
      )

      allow(blob.service).to receive(:bucket).and_return("test-bucket")

      described_class.transform_via_lambda(blob, transformations)

      variation = ActiveStorage::Variation.wrap(transformations)
      expect(blob.variant_records.find_by(variation_digest: variation.digest)).to be_present
    end
  end
end
