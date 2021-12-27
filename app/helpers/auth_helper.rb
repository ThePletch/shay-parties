module AuthHelper
  def user_or_guest
    if user_signed_in?
      current_user
    elsif params[:guest_guid] and guest = Guest.find_by(guid: params[:guest_guid])
      guest
    else
      nil
    end
  end
end
