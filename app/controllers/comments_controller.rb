class CommentsController < ApplicationController
  before_action :require_user_or_guest_auth
  before_action :set_event, only: [:create]
  before_action :set_parent, only: [:create_reply]
  before_action :set_manageable_comment, only: [:update, :destroy, :undelete]

  # TODO event owners should not have global edit permissions
  def update
    if @comment.update(comment_params.merge(editor: @authenticated_user))
      message = {notice: t('comment.updated')}
    else
      message = {alert: t('comment.updated_failed') + "#{@comment.errors}"}
    end

    redirect_to event_path(@comment.event, guest_guid: params[:guest_guid]), message
  end

  def destroy
    if @comment.update(deleted_at: Time.current, editor: @authenticated_user)
      message = {notice: t('comment.destroyed')}
    else
      message = {alert: t('comment.destroyed_failed')}
    end

    redirect_to event_path(@comment.event, guest_guid: params[:guest_guid]), message
  end

  def undelete
    if @comment.update(deleted_at: nil, editor: @authenticated_user)
      message = {notice: t('comment.undeleted')}
    else
      message = {alert: t('comment.undeleted_failed')}
    end

    redirect_to event_path(@comment.event, guest_guid: params[:guest_guid]), message
  end

  def create
    @comment = @event.comments.build(comment_params.merge(creator: @authenticated_user))

    if @comment.save
      message = {notice: t('comment.created')}
    else
      message = {alert: t('comment.created_failed') + "#{@comment.errors}"}
    end

    redirect_to event_path(@comment.event, guest_guid: params[:guest_guid]), message
  end

  def create_reply
    @comment = @parent_comment.children.build(comment_params.merge(
      event: @parent_comment.event,
      creator: @authenticated_user,
    ))

    if @comment.save
      message = {notice: t('comment.created')}
    else
      message = {alert: t('comment.created_failed') + "#{@comment.errors}"}
    end

    redirect_to event_path(@comment.event, guest_guid: params[:guest_guid]), message
  end

  private

  def require_user_or_guest_auth
    unless @authenticated_user
      redirect_to new_user_session_path, alert: t('comment.rejection.unauthenticated')
      return
    end
  end

  def set_manageable_comment
    begin
      @comment = @authenticated_user.comments.includes(:event, :editor).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      # if the user didn't make the comment, they can still edit/delete it
      # if they're the owner of the event the comment was posted on.
      target_comment = Comment.includes(:event, :editor).find(params[:id])
      if !@authenticated_user.guest? and target_comment.event.hosted_by?(@authenticated_user)
        @comment = target_comment
      else
        raise
      end
    end
  end

  def set_parent
    @parent_comment = Comment.includes(:creator, :event).find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end

  def set_event
    @event = Event.friendly.find(params[:event_id])
  end
end
