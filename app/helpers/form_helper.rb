module FormHelper
  include ActionView::Helpers::FormHelper

  def optional_parent_wrap(parent_form, form_record, options = {}, &block)
    if parent_form.present?
      record_object = form_record.kind_of?(Array) ? form_record.last : form_record
      if options[:record_name]
        parent_form.fields_for(options[:record_name], record_object, options, &block)
      else
        parent_form.fields_for(record_object, options, &block)
      end
    else
      bootstrap_form_for(form_record, options, &block)
    end
  end

  # helper that generates a link that, when pressed, adds the specified rendered block
  # to the specified location on the page
  def link_to_add_fields(name = nil, f = nil, association = nil, options = nil, html_options = nil, subform_options = {}, &block)
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
    options[:child_index] ||= 'new_record'
    fields = f.fields_for(association, new_object, options) do |builder|
      render(partial, locals.merge!(f: builder))
    end

    # The rendered fields are sent with the link within the data-form-prepend attr
    html_options['data-form-prepend'] = raw CGI::escapeHTML( fields )
    html_options['data-association-name'] = association
    html_options['data-prepend-child-index'] = options[:child_index]
    html_options['data-record-limit'] = options[:record_limit] if options.key?(:record_limit)
    html_options['data-target'] = target

    content_tag(:span, name, html_options, &block)
  end
end
