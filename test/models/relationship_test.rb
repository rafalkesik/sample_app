require "test_helper"

class RelationshipTest < ActiveSupport::TestCase

  def setup
    @relationship = Relationship.new(follower_id: users(:michael).id,
                                     followed_id: users(:archer).id  )
  end

  test "should be valid" do
    assert @relationship.valid?
  end

  test "should require a follower_id" do
    @relationship.follower_id = nil
    assert_not @relationship.valid?
  end

  test "should require a followed_id" do
    @relationship.followed_id = nil
    assert_not @relationship.valid?
  end

  test "should follow and unfollow user" do
    michael = users(:michael)
    dwight  = users(:dwight)
    assert_not michael.following?(dwight)
    michael.follow(dwight)
    assert michael.following?(dwight)
    assert michael.following.include?(dwight)
    assert dwight.followers.include?(michael)
    michael.unfollow(dwight)
    assert_not michael.following?(dwight)
  end
end
