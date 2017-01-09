class User < ActiveRecord::Base
  has_many :posts
  has_many :uploads, through: :posts

  has_secure_password

  validates :username, :password_digest, presence: true

  def self.find_by_slug(slug)
    self.all.find {|occurence| occurence.slug == slug}
  end

  def slug
    self.username.downcase.gsub(" ", "-")
  end
end
