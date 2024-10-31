require "test_helper"

class MicropostInterface < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    log_in_as @user
  end
end

class MicropostsInterfaceTest < MicropostInterface
  test "should paginate microposts" do
    get root_url
    assert_select 'div.pagination'
  end

  test "should show errors but not create micropost on invalid submission" do
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select 'div#error_explanation'
    assert_select 'a[href=?]', '/?page=2' #correct pagination link
  end

  test "should create a micropost on valid submission" do
    content = "pierdoła"
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content } }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
  end
  
  test "should have micropost delete links on own profile page" do
    get user_path(@user)
    assert_select 'a', text: 'delete'
  end

  test "should be able to delete own micropost" do
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
  end

  test "should not have delete links on other user's profile page" do
    get user_path(users(:archer))
    assert_select 'a', { text: 'delete', count: 0 }
  end
end

class MiropostSidebarTest < MicropostInterface
  test "should display the right amount of microposts" do
    get root_path
    assert_match "#{@user.microposts.count} microposts", response.body
  end

  test "should pluralize correctly for 0 microposts" do
    log_in_as (users(:dwight))
    get root_path
    assert_select 'span', text: "0 microposts"
  end

  test "should pluralize correctly for 1 micropost" do
    log_in_as users(:lana)
    get root_path
    assert_select 'span', text: '1 micropost'
  end
end

class ImageUploadTest < MicropostInterface
  test "should have a file input field for images" do
    get root_path
    assert_select 'input[type=?]', 'file'
  end

  test "should be able to attach an image" do
    # puts "THIS IS IT!!!!!"
    # puts Rails.configuration.active_storage.service
    cont = "Hello, world, let's get started!"
    img   = fixture_file_upload(Rails.root.join('test/fixtures/files/kitten.jpg'), 'image/jpeg')
    post microposts_path, params: { micropost: { content: cont, image: img } }
    micropost = assigns(:micropost)
    assert micropost.image.attached?
  end
end