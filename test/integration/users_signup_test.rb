require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  # test "the truth" do
  #   assert true
  # end

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup information" do
    get signup_path
    #無効なユーザーを作ろうとしてもユーザーが増えない
    #（すなわち、ユーザーが作られないことを確認）
    assert_no_difference 'User.count' do
      post signup_path, params: { user:{ name: "",
                                email:"user@invalid",
                                password:"foo",
                                password_confirmation:"bar"}}
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.alert'
    assert_select 'form[action="/signup"]'
  end

  test "valid signup information with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name: "Example User",
                                email: "user@example.com",
                                password: "password",
                                password_confirmation: "password"}}
    end
    assert_equal 1,ActionMailer::Base.deliveries.size
    #assignsを使うことで、アクション内のインスタンス変数(@変数)にアクセス可能になる.
    #アクセスする時は:変数として ハッシュのように扱う
    #メールが送られた数が1つであることを確認
    user = assigns(:user)
    assert_not user.activated?
    #有効化してない状態でログインしてみる
    log_in_as(user)
    assert_not is_logged_in?
    #有効化トークンが不正な場合
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    #トークンは正しいがメールアドレスが無効な場合
    get edit_account_activation_path(user.activation_token, email: "wrong")
    assert_not is_logged_in?
    #有効化トークンが正しい場合
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end

end
