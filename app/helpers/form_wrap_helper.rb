module FormWrapHelper
  include ActionView::Helpers::FormHelper

  def optional_parent_wrap(parent_form, form_record, options = {}, &block)
    if parent_form.present?
      parent_form.fields_for(:address, options, &block)
    else
      form_for(form_record, options, &block)
    end
  end
end
