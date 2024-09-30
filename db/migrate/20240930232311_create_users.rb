class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :sptf_user_id
      t.string :sptf_access_token
      t.string :sptf_token_type
      t.integer :sptf_expires_in
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
