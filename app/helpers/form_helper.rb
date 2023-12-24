module FormHelper
  include ActionView::Helpers::FormHelper

  def optional_parent_wrap(parent_form, form_record, options = {}, &block)
    if parent_form.present?
      record_object = form_record.kind_of?(Array) ? form_record.last : form_record
      parent_form.fields_for(record_object, options, &block)
    else
      bootstrap_form_for(form_record, options, &block)
    end
  end
end
