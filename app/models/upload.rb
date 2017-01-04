class Upload < ActiveRecord::Base
  belongs_to :user

  validates :photo, presence: true
end
