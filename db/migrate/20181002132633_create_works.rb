class CreateWorks < ActiveRecord::Migration[5.2]
  def change
    create_table :works do |t|
      t.references :user, index: true, foreign_key: true
      t.string :youtube_id
      t.string :title
      t.text :description
      t.string :thumbnail
      t.string :youtube_url
      t.timestamps

      t.index [:user_id, :created_at]
    end
  end
end
