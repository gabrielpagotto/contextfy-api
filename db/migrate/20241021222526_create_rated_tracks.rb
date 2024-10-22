class CreateRatedTracks < ActiveRecord::Migration[7.2]
  def change
    create_table :rated_tracks do |t|
      t.string :sptf_track_id, null: false
      t.integer :rate
      t.references :user, null: false, foreign_key: { to_table: :users }
      t.references :context, null: false, foreign_key: { to_table: :contexts }
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
