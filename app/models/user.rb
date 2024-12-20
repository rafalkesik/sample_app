class User < ApplicationRecord
    has_many :microposts, dependent: :destroy
    has_many :active_relationships,  class_name:  'Relationship',
                                     foreign_key: 'follower_id',
                                     dependent:   :destroy
    has_many :passive_relationships, class_name:  'Relationship',
                                     foreign_key: 'followed_id',
                                     dependent:   :destroy
    has_many :following, through: :active_relationships, source: :followed 
    has_many :followers, through: :passive_relationships, source: :follower
    attr_accessor :remember_token, :activation_token, :reset_token
    before_save :downcase_email
    before_create :create_activation_digest
    validates :name, presence: true, length: { maximum: 50 }
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },
                      format: { with: VALID_EMAIL_REGEX },
                      uniqueness: { case_sensitive: true }
    has_secure_password
    validates :password, presence: true, length: { minimum: 6 }

    # Returns the hash digest of the given string.
    def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                      BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end

    # Returns a random token.
    def User.new_token
        SecureRandom.urlsafe_base64
    end

    # Remembers a user in the database for use in persistent sessions.
    def remember
        self.remember_token = User.new_token
        self.update_attribute(:remember_digest, User.digest(remember_token))
        remember_digest
    end

    # Returns a session token to prevent session hijacking.
    # We reuse the remember digest for convenience.
    def session_token
        remember_digest || remember
    end

    # Forgets a user in the database
    def forget
        self.update_attribute(:remember_digest, nil)
    end

    # Returns true if the given token matches the digest.
    def authenticated?(attribute, token_value)
        digest = self.send("#{attribute}_digest")
        return false if digest.nil?
        BCrypt::Password.new(digest).is_password?(token_value)
    end

    # Sends activation email.
    def send_activation_email
        UserMailer.account_activation(self).deliver_now
    end

    # Activates an account.
    def activate
        self.update_columns(activated: true, activated_at: Time.zone.now)
    end

    # Cretes and assigns the reset token and digest.
    def create_reset_digest
        self.reset_token = User.new_token
        self.update_columns(reset_digest:  User.digest(self.reset_token),
                            reset_sent_at: Time.zone.now)
    end

    # Sends reset password email.
    def send_password_reset_email
        UserMailer.password_reset(self).deliver_now
    end

    # Returns true if the password reset has expired (>2h have passed since reset creation).
    def password_reset_expired?
        self.reset_sent_at < 2.hours.ago
    end

    # Returns a user's status feed.
    def feed
        following_ids_subselect = "SELECT followed_id FROM relationships
                                   WHERE  follower_id = :user_id"
        Micropost.where("user_id IN (#{following_ids_subselect}) 
                         OR user_id = :user_id", user_id: self.id)
    end

    # Better feed.
    def feed
        part_of_feed = "relationships.follower_id = :id
                        OR microposts.user_id = :id"
        Micropost.left_outer_joins(user: :followers)
                 .where(part_of_feed, { id: self.id }).distinct
                 .includes(:user, image_attachment: :blob)
    end

    # Follows a user.
    def follow(other_user)
        following << other_user unless self == other_user
    end

    # Unfollows a user.
    def unfollow(other_user)
        following.delete(other_user)
    end

    # Returns true if current user is following the other_user.
    def following?(other_user)
        following.include?(other_user)
    end

    private

        # Converts email to all lower-case.
        def downcase_email
            self.email = email.downcase
        end

        # Creates and assigns the activation token and digest.
        def create_activation_digest
            self.activation_token  = User.new_token
            self.activation_digest = User.digest(activation_token)
        end
end
