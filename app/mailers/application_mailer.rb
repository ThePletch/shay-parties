class ApplicationMailer < ActionMailer::Base
  default from: -> { "noreply@#{ENV.fetch('PARTIES_BASE_DOMAIN', 'example.com')}" }
  layout 'mailer'
end
