class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.string :category, null: false
      t.string :author_name, null: false
      t.references :user, null: false, foreign_key: true
      
      # 마일스톤 전용 필드
      t.date :milestone_date
      t.string :milestone_status
      t.string :last_editor_name
      t.datetime :last_edited_at

      t.timestamps
    end
    
    add_index :posts, :category
    add_index :posts, :created_at
    add_index :posts, [:category, :created_at]
  end
end
