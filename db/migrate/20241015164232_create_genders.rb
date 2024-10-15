class CreateGenders < ActiveRecord::Migration[7.2]
  def change
    create_table :genders do |t|
      t.string :sptf_gender_id
      t.references :user, null: false, foreign_key: { to_table: :users }
      t.datetime :deleted_at
    end
  end
end
