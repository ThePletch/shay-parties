# frozen_string_literal: true

Rails.application.config.to_prepare do
  unless ActiveStorage::TransformJob.ancestors.include?(ActiveStorage::LambdaTransform)
    ActiveStorage::TransformJob.prepend(ActiveStorage::LambdaTransform)
  end
end
