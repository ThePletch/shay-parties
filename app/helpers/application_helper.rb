module ApplicationHelper
  def current_locale_emoji
    locale_emoji(I18n.locale)
  end

  def locale_emoji(locale)
    case locale
    when :en
      return %w(🇺🇸).sample
    when :es
      return %w(🇦🇷 🇬🇹 🇲🇽 🇻🇪 🇨🇱 🇵🇷).sample
    end
  end

  def scope(name, path, scope_name)
    scope_classes = ['btn', 'btn-sm', 'btn-secondary']
    scope_classes << 'active' if @current_scope == scope_name.to_s
    link_to(name, path, class: scope_classes)
  end

  def title(page_title)
    content_for(:title) { page_title }
  end
end
