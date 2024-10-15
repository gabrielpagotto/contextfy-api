class Gender < ApplicationRecord
  validates :name, presence: true
  validates :sptf_gender_id, presence: true
  validates :user_id, presence: true

  belongs_to :user
end
