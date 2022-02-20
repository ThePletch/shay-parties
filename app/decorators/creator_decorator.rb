class CreatorDecorator < Draper::Decorator
  delegate :name

  def gravatar_url
    # 60px avatars with the identicon style for people without a custom gravatar
    # todo config settings for this
    options = {s: 60, d: 'identicon'}
    "https://secure.gravatar.com/avatar/#{Digest::MD5.hexdigest(object.email)}?#{options.to_query}"
  end
end
