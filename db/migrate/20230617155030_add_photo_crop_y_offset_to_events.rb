class AddPhotoCropYOffsetToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :photo_crop_y_offset, :integer, null: false, default: 0
  end
end
