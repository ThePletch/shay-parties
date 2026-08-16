# frozen_string_literal: true

module AdminHelper
  def role_badge_class(role)
    case role
    when "admin"
      "text-bg-primary"
    when "superadmin"
      "text-bg-dark"
    when "suspended"
      "text-bg-warning"
    when "banned"
      "text-bg-danger"
    else
      "text-bg-secondary"
    end
  end
end
