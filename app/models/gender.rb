class Gender < ApplicationRecord
  validates :sptf_gender_id, presence: true
  validates :user_id, presence: true

  belongs_to :user
end
