# frozen_string_literal: true

require "base64"
require "json"
require "tempfile"

require "aws-sdk-s3"
require "image_processing/mini_magick"

module ImageTransform
  module_function

  def apply(bucket:, source_key:, transformations:, content_type:)
    s3 = Aws::S3::Client.new

    Tempfile.create(["source", File.extname(source_key)]) do |source_file|
      s3.get_object(bucket: bucket, key: source_key, response_target: source_file.path)

      output = transform_file(source_file.path, transformations, content_type)

      {
        statusCode: 200,
        body: Base64.strict_encode64(File.binread(output.path)),
        contentType: output_content_type(output_format(transformations, content_type))
      }
    end
  end

  def transform_file(source_path, transformations, content_type)
    format = output_format(transformations, content_type)
    operations = build_operations(transformations)

    ImageProcessing::MiniMagick
      .source(source_path)
      .loader(page: 0)
      .convert(format)
      .apply(operations)
      .call
  end

  def build_operations(transformations)
    transformations.each_with_object([]) do |(name, argument), list|
      next if argument.blank?

      list << [name.to_sym, argument]
    end
  end

  def output_format(transformations, content_type)
    transformations["format"]&.to_sym || default_format(content_type)
  end

  def default_format(content_type)
    if content_type.in?(%w[image/png image/gif])
      :png
    else
      :jpg
    end
  end

  def output_content_type(format)
    case format.to_sym
    when :png then "image/png"
    when :gif then "image/gif"
    else "image/jpeg"
    end
  end
end

def lambda_handler(event:, _context:)
  payload = event.is_a?(String) ? JSON.parse(event) : event

  ImageTransform.apply(
    bucket: payload.fetch("bucket"),
    source_key: payload.fetch("source_key"),
    transformations: payload.fetch("transformations"),
    content_type: payload.fetch("content_type")
  )
rescue StandardError => error
  {
    statusCode: 500,
    body: error.message
  }
end
