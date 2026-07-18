# frozen_string_literal: true

require "rails_helper"
require "aws-sdk-lambda"

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

  around do |example|
    original = {
      "ACTIVE_STORAGE_TRANSFORM_LAMBDA" => ENV["ACTIVE_STORAGE_TRANSFORM_LAMBDA"],
      "ACTIVE_STORAGE_S3_REGION" => ENV["ACTIVE_STORAGE_S3_REGION"]
    }
    ENV["ACTIVE_STORAGE_TRANSFORM_LAMBDA"] = "test-image-transform"
    ENV["ACTIVE_STORAGE_S3_REGION"] = "us-east-2"
    example.run
  ensure
    original.each do |key, value|
      if value.nil?
        ENV.delete(key)
      else
        ENV[key] = value
      end
    end
  end

  describe ".transform_via_lambda" do
    it "creates a variant record from the Lambda response" do
      lambda_client = instance_double(Aws::Lambda::Client)
      allow(Aws::Lambda::Client).to receive(:new)
        .with(region: "us-east-2", use_dualstack_endpoint: true)
        .and_return(lambda_client)
      allow(lambda_client).to receive(:invoke).and_return(
        double(
          function_error: nil,
          payload: StringIO.new({
            statusCode: 200,
            body: Base64.strict_encode64(file_fixture("test_image.png").binread),
            contentType: "image/png"
          }.to_json)
        )
      )

      without_partial_double_verification do
        allow(blob.service).to receive(:bucket).and_return("test-bucket")
      end

      expect {
        described_class.transform_via_lambda(blob, transformations)
      }.to change {
        ActiveStorage::VariantRecord.where(blob_id: blob.id).count
      }.from(0).to(1)
    end
  end
end
