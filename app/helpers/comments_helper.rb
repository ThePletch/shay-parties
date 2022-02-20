module CommentsHelper
  def children_from(parent_comment, comments)
    comments.select{|c| c.parent_id == parent_comment.id }
  end
end
