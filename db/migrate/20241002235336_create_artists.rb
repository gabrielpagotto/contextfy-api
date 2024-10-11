class CreateArtists < ActiveRecord::Migration[7.2]
  def change
    create_table :artists do |t|
      t.string :sptf_artist_id
      t.references :user, null: false, foreign_key: { to_table: :users }
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
