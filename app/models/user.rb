class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: "Relationship",
                                        foreign_key: "follower_id",
                                        dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship",
  foreign_key: "followed_id",
  dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save :downcase_email
  before_create :create_activation_digest
  validates :name, presence: true, length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 255},
  format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive:false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6}, allow_nil: true

  #渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  #永続セッションのためにユーザーをデータベースに記憶する
  def remember
    #                    ランダムなトークン
    self.remember_token = User.new_token
    #Userテーブルの :remember_digest の値を更新 digestさせることでunaccessible
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  #is_password? は == と同じ働き

  def forget
    update_attribute(:remember_digest, nil)
  end

  def activate
    # update_attribute(:activated, true)
    # update_attribute(:activated_at, Time.zone.now)
    update_columns(activated: true, activated_at: Time.zone.now)
  end
  #selfの呼び出しは必須ではない。Userモデル内なのでどのテーブルかわかってる？

  def send_activation_email
    #モデルでは変数 user を定義していないので self
    UserMailer.account_activation(self).deliver_now
  end

  #パスワード再設定ののメールを送信する
  def create_reset_digest
    self.reset_token = User.new_token
    # update_attribute(:reset_digest, User.digest(reset_token))
    # update_attribute(:reset_sent_at, Time.zone.now)
    update_columns(reset_digest: User.digest(reset_token),
                   reset_sent_at: Time.zone.now )
  end

  #パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
    #2 hours ago より前に送られてるか？=２時間以上経過している
  end

  def feed
    #セキュリティ ? でエスケープ
    Micropost.where("user_id = ?",id)
  end

  def follow(other_user)
    following << other_user
  end

  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  def following?(other_user)
    following.include?(other_user)
  end

  private

  def downcase_email
    self.email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

end
