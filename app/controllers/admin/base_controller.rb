# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!

    private

    def require_admin!
      return if current_user.admin?

      redirect_to root_path, alert: t("admin.rejection.not_admin")
    end
  end
end
