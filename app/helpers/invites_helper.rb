# frozen_string_literal: true

module InvitesHelper
  def link_to_add_invite_recipient(name, html_options = {})
    fields = render(
      partial: "invites/recipient_fields",
      locals: { index: "new_record", recipient: { selected: true } }
    )
    html_options = html_options.stringify_keys
    html_options["data-form-prepend"] = raw CGI.escapeHTML(fields)
    html_options["data-association-name"] = "recipients"
    html_options["data-prepend-child-index"] = "new_record"
    html_options["data-record-limit"] = InviteSend::DAILY_LIMIT
    html_options["data-target"] = "#invite-recipients"
    content_tag(:span, name, html_options)
  end
end
