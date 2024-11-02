class User < ApplicationRecord
  validates :sptf_user_id, presence: true

  has_many :artists
  has_many :genders
  has_many :contexts
  has_many :rated_tracks
  has_many :playlists
end
