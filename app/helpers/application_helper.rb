module ApplicationHelper
  def current_locale_emoji
    case I18n.locale
    when :en
      return "🇺🇸"
    when :es
      return "🇲🇽"
    end
  end

  # helper that generates a link that, when pressed, adds the specified rendered block
  # to the specified location on the page
  def link_to_add_fields(name = nil, f = nil, association = nil, options = nil, html_options = nil, &block)
    # If a block is provided there is no name attribute and the arguments are
    # shifted with one position to the left. This re-assigns those values.
    f, association, options, html_options = name, f, association, options if block_given?

    options = {} if options.nil?
    html_options = {} if html_options.nil?
    if options.include? :locals
      locals = options[:locals]
    else
      locals = {}
    end

    if options.include? :partial
      partial = options[:partial]
    else
      partial = association.to_s.singularize + '_fields'
    end

    target = options[:target]

    # Render the form fields from a file with the association name provided
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, child_index: 'new_record') do |builder|
      render(partial, locals.merge!( f: builder))
    end

    # The rendered fields are sent with the link within the data-form-prepend attr
    html_options['data-form-prepend'] = raw CGI::escapeHTML( fields )
    html_options['data-association-name'] = association
    html_options['data-target'] = target

    content_tag(:span, name, html_options, &block)
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
