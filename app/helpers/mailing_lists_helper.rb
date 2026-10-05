module MailingListsHelper
  def mailing_list_filter_params
    params.permit(:scope, :event_id, :q).to_h.compact_blank.symbolize_keys
  end

  def mailing_list_filter_class(active)
    "btn btn-sm #{active ? "btn-primary" : "btn-outline-primary"}"
  end
end
