require "test_helper"

class RelationshipsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @relationship = relationships(:one)
  end

  test "should redirect create if not logged in" do
    assert_no_difference 'Relationship.count' do
      post relationships_path, params: { follower_id: 1, followed_id: 2 }
    end
    assert_redirected_to login_url
    assert_response :see_other
  end

  test "should redirect destroy if not logged in" do
    assert_no_difference 'Relationship.count' do
      delete relationship_path(@relationship)
    end
    assert_redirected_to login_url
    assert_response :see_other
  end
end
