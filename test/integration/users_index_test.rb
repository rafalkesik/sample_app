require "test_helper"

class UsersIndex < ActionDispatch::IntegrationTest

  def setup
    @admin = users(:michael)
    @non_admin = users(:dwight)
    @first_page_of_users = User.where(activated: true).paginate(page: 1)
  end
end

class UsersIndexAdmin < UsersIndex
  def setup
    super
    log_in_as(@admin)    
    get users_path
  end
end

class UsersIndexAdminTest < UsersIndexAdmin
  
  test "template" do
    assert_template 'users/index'
  end

  test "pagination elements" do
    assert_select "div.pagination", count: 2
  end

  test "users names, links and delete buttons" do
    @first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete',
                                                  method: :delete
      end
    end
  end

  test "should be able to delete non-admin user" do
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
    assert_response :see_other
    assert_redirected_to users_url
  end
  
  test "should display only activated users" do
    User.paginate(page: 1).first.toggle!(:activated)
    get users_path
    assigns(:users).each do |user|
      assert user.activated?
    end
  end
end
  
class UsersIndexNonAdmin < UsersIndex
  def setup
    super
    log_in_as(@non_admin)
    get users_path
  end
end

class UsersIndexNonAdminTest < UsersIndexNonAdmin
  test "should not show delete buttons as non-admin" do
    assert_select 'a', text: 'delete', count: 0
  end
end
