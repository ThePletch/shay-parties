module FormHelper
  include ActionView::Helpers::FormHelper
  include StimulusHelper

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

  def dynamic_list(add_label, form, association, options = {}, **html_options, &block)
    options = options.dup
    locals = options.delete(:locals) || {}
    partial = options.delete(:partial) || "#{association.to_s.singularize}_fields"
    record_limit = options.delete(:record_limit)
    options[:child_index] ||= "new_#{association}"

    wrapper_data = {
      controller: "dynamic-list",
      action: stimulus_action("dynamic-list-record:changed", "dynamic-list", "enforceLimit"),
      dynamic_list_child_index_value: options[:child_index],
    }
    wrapper_data[:dynamic_list_record_limit_value] = record_limit unless record_limit.nil?

    content_tag(:div, data: wrapper_data) do
      rows = content_tag(:div, block_given? ? capture(&block) : nil, data: { dynamic_list_target: "rows" })
      if add_label.present?
        new_object = form.object.class.reflect_on_association(association).klass.new
        fields = form.fields_for(association, new_object, options) do |builder|
          render(partial, locals.merge(f: builder))
        end
        safe_join([
          content_tag(:template, fields, data: { dynamic_list_target: "template" }),
          rows,
          dynamic_list_add_button(add_label, html_options),
        ])
      else
        rows
      end
    end
  end

  def dynamic_list_record_hidden_fields(form)
    return unless form.object.persisted?

    destroy_value = form.object.marked_for_destruction? ? "1" : "0"
    safe_join([
      form.hidden_field(:id),
      form.hidden_field(:_destroy, value: destroy_value, data: { dynamic_list_record_target: "destroy" }),
    ])
  end

  def dynamic_list_record_delete_button
    tag.button(
      type: "button",
      class: "btn btn-danger",
      data: {
        dynamic_list_record_target: "deleteButton",
        action: stimulus_action("click", "dynamic-list-record", "delete"),
      },
    ) do
      safe_join([
        tag.span("X", class: "dynamic-list-record-remove-label"),
        tag.span("+", class: "dynamic-list-record-restore-label"),
      ])
    end
  end

  private

  def dynamic_list_add_button(add_label, html_options)
    html_options = html_options.dup
    html_options[:type] = "button"
    html_options[:data] = (html_options[:data] || {}).merge(
      action: stimulus_action("click", "dynamic-list", "add"),
      dynamic_list_target: "addButton",
    )
    tag.button(add_label, **html_options)
  end
end
