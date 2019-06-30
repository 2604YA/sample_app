module SessionsHelper
  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end

 # 現在ログイン中のユーザーを返す (いる場合)
  def current_user
    if session[:user_id]
      #@current_user = @current_user or(||) 探す
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end

# ユーザーがログインしていればtrue、その他ならfalseを返す
#current_userがnilじゃない = いる ログインしている状態
  def logged_in?
    !current_user.nil?
  end

  def log_out
    #session と current_user両方から削除
    session.delete(:user_id)
    @current_user = nil
  end

end
