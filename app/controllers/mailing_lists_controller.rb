class MailingListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_mailing_list, only: [:show, :edit, :update, :destroy, :sync_users, :add_emails]

  def index
    @mailing_lists = current_user.mailing_lists.includes(:emails).order(:name)
  end

  def show
    @events = current_user.managed_events.order(start_time: :desc)
    @emails = filtered_emails
  end

  def new
    @mailing_list = MailingList.new
  end

  def edit
  end

  def create
    @mailing_list = current_user.mailing_lists.build(mailing_list_params)

    if @mailing_list.save
      redirect_to @mailing_list, notice: t("mailing_list.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @mailing_list.update(mailing_list_params)
      redirect_to @mailing_list, notice: t("mailing_list.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @mailing_list.destroy
    redirect_to mailing_lists_url, notice: t("mailing_list.destroyed")
  end

  def sync_users
    unmatched_before = @mailing_list.emails.where(user_id: nil).count
    @mailing_list.sync_users
    linked = unmatched_before - @mailing_list.emails.where(user_id: nil).count
    redirect_to mailing_list_path(@mailing_list, **helpers.mailing_list_filter_params), notice: t("mailing_list.synced", count: linked)
  end

  def add_emails
    result = @mailing_list.add_addresses(params[:addresses])
    if result[:invalid].any?
      flash[:alert] = t("mailing_list.invalid_emails", emails: result[:invalid].join(", "))
    end
    if result[:added].any?
      flash[:notice] = t("mailing_list.added", count: result[:added].size)
    elsif result[:invalid].empty?
      flash[:alert] = t("mailing_list.none_to_add")
    end
    redirect_to mailing_list_path(@mailing_list, **helpers.mailing_list_filter_params)
  end

  private

  def set_mailing_list
    @mailing_list = current_user.mailing_lists.find(params[:id])
  end

  def mailing_list_params
    params.require(:mailing_list).permit(:name)
  end

  def filtered_emails
    emails = @mailing_list.emails
    query = params[:q].to_s.strip
    if query.present?
      term = "%#{ActiveRecord::Base.sanitize_sql_like(query)}%"
      emails = emails.where(
        "mailing_list_emails.email ILIKE :term OR mailing_list_emails.user_id IN (SELECT id FROM users WHERE name ILIKE :term)",
        term: term
      )
    end

    @list_scope = params[:scope].presence_in(%w[exclude_no_rsvps attendees])
    @event = nil
    if @list_scope && params[:event_id].present?
      @event = @events.find(params[:event_id])
      emails = case @list_scope
      when "exclude_no_rsvps"
        emails.no_decline_rsvp_for_event(@event)
      when "attendees"
        emails.attending_event(@event)
      end
    else
      @list_scope = nil
    end

    emails.includes(:user).distinct
  end
end
