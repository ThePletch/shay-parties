class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def strict_loading_n_plus_one_only?
    true
  end
end
