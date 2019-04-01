class MailingListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_mailing_list, only: [:show, :edit, :update, :destroy, :sync_users]

  def index
    @mailing_lists = current_user.mailing_lists
  end

  def show
    case params[:scope]
    when 'exclude_no_rsvps'
      event = current_user.managed_events.find(params[:event_id])
      @emails = @mailing_list.emails.no_decline_rsvp_for_event(event)
    when 'attendees'
      event = current_user.managed_events.find(params[:event_id])
      @emails = @mailing_list.emails.attending_event(event)
    else
      @emails = @mailing_list.emails
    end
  end

  def new
    @mailing_list = MailingList.new
  end

  def edit
  end

  def create
    @mailing_list = current_user.mailing_lists.build(mailing_list_params)

    if @mailing_list.save
      redirect_to @mailing_list, notice: 'Mailing list was successfully created.'
    else
      render :new
    end
  end

  def update
    if @mailing_list.update(mailing_list_params)
      redirect_to @mailing_list, notice: 'Mailing list was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @mailing_list.destroy
    redirect_to events_url, notice: 'Mailing list was successfully destroyed.'
  end

  def sync_users
    @mailing_list.sync_users
    redirect_to @mailing_list, notice: 'Users synced to mailing list.'
  end

  private

  def set_mailing_list
    @mailing_list = current_user.mailing_lists.includes(:emails).find(params[:id])
  end

  def mailing_list_params
    params.require(:mailing_list).permit(:name, emails_attributes: [:_destroy, :id, :email])
  end
end
