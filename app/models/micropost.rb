class Micropost < ApplicationRecord
  belongs_to       :user
  has_one_attached :image # Images are not resized to smaller, because I could not install ImageMagick. Only their width and height are changed in the custom.scss file. This might slow down page load time.
  default_scope -> { order('created_at DESC') }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :image,   content_type: { in: %w[image/jpeg image/gif image/png],
                                      message: "must be a valid image format" },
                      size:         { less_than: 5.megabytes,
                                      message:   "should be less than 5MB" }
end
