class User < ApplicationRecord
  validates :sptf_user_id, presence: true

  has_many :artists
end
