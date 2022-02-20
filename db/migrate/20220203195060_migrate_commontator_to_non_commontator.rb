class MigrateCommontatorToNonCommontator < ActiveRecord::Migration[6.1]
  def change
    # mapping from the OLD id of the parent to the NEW id of any children (array)
    lineage_mapping = Hash.new{|h, k| h[k] = [] }
    # mapping from OLD id to NEW id
    migration_mapping = {}

    # create all the comments without any lineage, since the order in which they spin up
    # isn't guaranteed
    Commontator::Comment.includes(:thread).all.each do |comment|
      new_comment = Comment.create(
        creator: comment.creator,
        editor: comment.editor,
        event: comment.thread.commontable,
        deleted_at: comment.deleted_at,
        body: comment.body,
      )
      puts "Created new comment ID #{new_comment.id} with old parent ID #{comment.parent_id}"
      lineage_mapping[comment.parent_id].push(new_comment.id)
      puts "Mapping ID #{comment.id} to #{new_comment.id}"
      migration_mapping[comment.id] = new_comment.id
    end

    # assemble the comments into parents and children now that all comments are guaranteed
    # to exist in the new table
    lineage_mapping.each do |old_id, new_child_ids|
      puts old_id
      puts new_child_ids
      Comment.where(id: new_child_ids).update(parent_id: migration_mapping[old_id])
    end
  end
end
