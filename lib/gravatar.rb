require "digest"

module Gravatar
  class << self
    # 60px avatars with the identicon style for people without a custom gravatar
    # todo config settings for this
    def url(email, size: 60)
      options = { s: size, d: "identicon" }
      "https://secure.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}?#{options.to_query}"
    end
  end
end
