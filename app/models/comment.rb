class Comment < ActiveRecord::Base
  belongs_to :event

  belongs_to :creator, polymorphic: true
  belongs_to :editor, polymorphic: true, optional: true

  belongs_to :parent, class_name: "Comment", optional: true
  has_many :children, class_name: "Comment", foreign_key: :parent_id

  def deleted?
    deleted_at.present?
  end

  def edited?
    !editor.nil?
  end

  def deletable_by?(user)
    creator == user or event.owned_by?(user)
  end

  def editable_by?(user)
    creator == user
  end

end
