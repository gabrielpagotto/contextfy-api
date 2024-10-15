class CreateContexts < ActiveRecord::Migration[7.2]
  def change
    create_table :contexts do |t|
      t.string :name
      t.float :latitude
      t.float :longitude
      t.references :user, null: false, foreign_key: { to_table: :users }
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
