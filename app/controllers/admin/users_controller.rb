# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    PER_PAGE = 25

    before_action :set_user, only: %i[show suspend unsuspend ban unban promote demote clear_invite_restriction]

    def index
      scope = filtered_users
      @total_count = scope.count
      @page = [params[:page].to_i, 1].max
      @total_pages = [(@total_count.to_f / PER_PAGE).ceil, 1].max
      @page = @total_pages if @page > @total_pages
      @users = scope.order(created_at: :desc).offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
    end

    def show
      @banned_email = BannedEmail.find_by(email: BannedEmail.normalize(@user.email))
    end

    def suspend
      moderate { @user.suspend!(actor: current_user) }
    end

    def unsuspend
      moderate { @user.unsuspend!(actor: current_user) }
    end

    def ban
      moderate { @user.ban!(actor: current_user, reason: params[:reason]) }
    end

    def unban
      moderate { @user.unban!(actor: current_user) }
    end

    def promote
      moderate { @user.promote_to_admin!(actor: current_user) }
    end

    def demote
      moderate { @user.demote_from_admin!(actor: current_user) }
    end

    def clear_invite_restriction
      moderate { @user.clear_invite_send_restriction!(actor: current_user) }
    end

    private

    def set_user
      @user = User.friendly.find(params[:id])
    end

    def moderate
      yield
      redirect_to admin_user_path(@user), notice: t("admin.users.flash.#{action_name}")
    rescue User::ModerationError => e
      redirect_to admin_user_path(@user), alert: e.message
    end

    def filtered_users
      scope = User.all

      if params[:q].present?
        query = "%#{User.sanitize_sql_like(params[:q].to_s.strip)}%"
        scope = scope.where("users.email ILIKE :q OR users.name ILIKE :q", q: query)
      end

      if params[:role].present? && User::ROLES.include?(params[:role])
        scope = scope.where(role: params[:role])
      end

      case params[:confirmed]
      when "yes"
        scope = scope.where.not(confirmed_at: nil)
      when "no"
        scope = scope.where(confirmed_at: nil)
      end

      scope
    end
  end
end
