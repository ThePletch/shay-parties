class MailingListEmailsController < ApplicationController
  helper MailingListsHelper

  before_action :authenticate_user!

  def destroy
    mailing_list = current_user.mailing_lists.find(params[:mailing_list_id])
    email = mailing_list.emails.find(params[:id])
    email.destroy!
    redirect_to mailing_list_path(mailing_list, **helpers.mailing_list_filter_params), notice: t("mailing_list.removed", email: email.email)
  end
end
