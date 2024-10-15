class Artist < ApplicationRecord
  validates :sptf_artist_id, presence: true
  validates :user_id, presence: true

  belongs_to :user
end
