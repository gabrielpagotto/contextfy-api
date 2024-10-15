class User < ApplicationRecord
  validates :sptf_user_id, presence: true

  has_many :artists
  has_many :genders
  has_many :contexts
end
