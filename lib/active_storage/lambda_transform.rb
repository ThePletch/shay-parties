# frozen_string_literal: true

require "base64"
require "stringio"

module ActiveStorage
  module LambdaTransform
    def perform(blob, transformations)
      if LambdaTransform.lambda_transform_enabled?
        LambdaTransform.transform_via_lambda(blob, transformations)
      else
        super
      end
    end

    class << self
      def lambda_transform_enabled?
        ENV["ACTIVE_STORAGE_TRANSFORM_LAMBDA"].present?
      end

      def transform_via_lambda(blob, transformations)
        representation = blob.representation(transformations)
        variation = representation.variation

        return if blob.variant_records.exists?(variation_digest: variation.digest)

        io, content_type = invoke_lambda(blob, variation)

        ActiveRecord::Base.connected_to(role: ActiveRecord.writing_role) do
          blob.variant_records.create_or_find_by!(variation_digest: variation.digest) do |record|
            record.image.attach(
              io: io,
              filename: representation.filename.to_s,
              content_type: content_type,
              service_name: blob.service.name
            )
          end
        end
      end

      private

      def invoke_lambda(blob, variation)
        require "aws-sdk-lambda"

        client = Aws::Lambda::Client.new(
          region: ENV.fetch("ACTIVE_STORAGE_S3_REGION", ENV.fetch("AWS_REGION", "us-east-2")),
          use_dualstack_endpoint: true
        )

        response = client.invoke(
          function_name: ENV.fetch("ACTIVE_STORAGE_TRANSFORM_LAMBDA"),
          invocation_type: "RequestResponse",
          payload: {
            bucket: active_storage_bucket_name(blob),
            source_key: blob.key,
            transformations: stringify_transformations(variation.transformations),
            content_type: blob.content_type
          }.to_json
        )

        if response.function_error.present?
          raise ActiveStorage::IntegrityError, response.payload.string
        end

        payload = JSON.parse(response.payload.string)
        status_code = payload.fetch("statusCode")
        unless status_code == 200
          raise ActiveStorage::IntegrityError, payload.fetch("body", "Lambda transform failed")
        end

        [
          StringIO.new(Base64.decode64(payload.fetch("body"))),
          payload.fetch("contentType")
        ]
      end

      def stringify_transformations(transformations)
        transformations.each_with_object({}) do |(key, value), hash|
          hash[key.to_s] = case value
                           when Symbol then value.to_s
                           else value
                           end
        end
      end

      def active_storage_bucket_name(blob)
        bucket = blob.service.bucket
        bucket.respond_to?(:name) ? bucket.name : bucket
      end
    end
  end
end
