# frozen_string_literal: true

require "base64"
require "fileutils"
require "rspec"
require_relative "../handler"

RSpec.describe "ImageTransform lambda handler" do
  it "runs without ActiveSupport" do
    expect(defined?(ActiveSupport)).to be_nil
  end

  it "transforms an image from S3 and returns a base64 body" do
    fixture = File.expand_path("fixtures/test_image.png", __dir__)
    s3 = instance_double(Aws::S3::Client)
    allow(Aws::S3::Client).to receive(:new).and_return(s3)
    allow(s3).to receive(:get_object) do |response_target:, **|
      FileUtils.cp(fixture, response_target)
    end

    result = lambda_handler(
      event: {
        "bucket" => "test-bucket",
        "source_key" => "uploads/test_image.png",
        "transformations" => {
          "resize" => "100",
          "crop" => "100x50+0+0"
        },
        "content_type" => "image/png"
      },
      context: nil
    )

    expect(result[:statusCode]).to eq(200)
    expect(result[:contentType]).to eq("image/png")
    expect(Base64.decode64(result[:body]).bytesize).to be > 0
  end
end
