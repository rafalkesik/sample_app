require "test_helper"

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name: "", email: "user@invalid", password: "invalid", password_confirmation: "invalid1" } }

    assert_response :unprocessable_entity
    assert_template 'users/edit'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
    assert_select "div.alert", text: 'The form contains 3 errors.'
  end

  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_path(@user)
    assert session[:forwarding_url].blank?
    patch user_path(@user), params: { user: { name: @user.name, email: @user.email, password: "password", password_confirmation: "password" } }
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.blank?
    @user.reload
    assert_equal "Michael Example", @user.name
    assert_equal "michael@example.com", @user.email
    assert_select "section.user_info", text: "Michael Example"
  end
end
