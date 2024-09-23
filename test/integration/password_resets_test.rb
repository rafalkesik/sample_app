require "test_helper"

class PasswordResets < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end
end

class ForgotPasswordFormTest < PasswordResets
  
  test "forgot password path" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'
  end

  test "forgot password with invalid email" do
    post password_resets_path, params: { password_reset: { email: "" } }
    assert_response :unprocessable_entity
    assert_not flash.empty?
    assert_template 'password_resets/new'
  end
end

class ResetPasswordForm < PasswordResets

  def setup
    super
    post password_resets_path, params: { password_reset: { email: @user.email } }
    @reset_user = assigns(:user)
  end
end

class ResetPasswordFormTest < ResetPasswordForm

  test "forgot password with valid email" do
    assert_not_equal @user.reset_digest,
                     @reset_user.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    assert_response :see_other
  end

  test "password reset with wrong email" do
    get edit_password_reset_path(id: @reset_user.reset_token, email: "")
    assert_redirected_to root_url
  end

  test "password reset with inactive user" do
    @reset_user.toggle!(:activated)
    get edit_password_reset_path(id: @reset_user.reset_token,
                                 email: @reset_user.email)
    assert_redirected_to root_url
  end

  test "password reset with right email but wrong token" do
    get edit_password_reset_path(id: 'wrong token',
                                 email: @reset_user.email)
    assert_redirected_to root_url
  end

  test "password reset with right email and right token" do
    get edit_password_reset_path(id: @reset_user.reset_token,
                                 email: @reset_user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", @reset_user.email
  end
end

class UpdatePasswordTest < ResetPasswordForm
  test "update with invalid password and confirmation" do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "foobar",
                            password_confirmation: "bazqur" } }
    assert_select 'div#error_explanation'
  end

  test "update with empty password and confirmation" do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "",
                            password_confirmation: "" } }
    assert_select 'div#error_explanation'
  end

  test "update with valid password and confirmation" do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "foobaz" } }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to @reset_user
    assert_nil @user.reload.reset_digest
    
    # Test second reset attempt.
    patch password_reset_path(@reset_user.reset_token),
    params: { email: @reset_user.email,
              user: { password:              "foobaz",
                      password_confirmation: "foobaz" } }
    assert_redirected_to root_url
  end
end

class ExpiredToken < PasswordResets
  def setup
    super
    # Create password reset token
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    @reset_user = assigns(:user)
    # Expire token by hand
    @reset_user.update_attribute(:reset_sent_at, 3.hours.ago)
    # Attempt to update user's password
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "foobaq",
                            password_confirmation: "foobaq" } }
  end
end

class ExpiredTokenTest < ExpiredToken
  test "should redirect to the password-reset page" do
    assert_redirected_to new_password_reset_url
  end

  test "should render flash when password expired" do
    follow_redirect!
    assert_match /expired/i, response.body
  end
end