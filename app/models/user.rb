class User < ApplicationRecord
  validates :sptf_user_id, presence: true
end
