require_relative '../../test_helper'

class Subscriber::FavoritesControllerTest < ActionController::TestCase

  setup do
    @subscriber = FactoryGirl.create :subscriber
    @nonprofit = FactoryGirl.create :nonprofit

    login_subscriber @subscriber
  end

  test "adding favorite not previously faved" do
    get :create, subscriber_guid: @subscriber.guid, id: @nonprofit.id

    assert_redirected_to subscriber_favorites_path(@subscriber.guid)
    assert flash[:notice] =~ /added/
    assert_equal 1, Subscriber.first.favorite_nonprofits.count
  end

  test "adding favorite previously faved" do
    @subscriber.favorite_nonprofits << @nonprofit
    get :create, subscriber_guid: @subscriber.guid, id: @nonprofit.id

    assert_redirected_to subscriber_favorites_path(@subscriber.guid)
    assert_equal 1, Subscriber.first.favorite_nonprofits.count
    assert flash[:notice] =~ /already/
  end

  test "adding non-existent nonprofit" do
    get :create, subscriber_guid: @subscriber.guid, id: 9999999

    assert_redirected_to subscriber_path(@subscriber.guid)
    assert_equal 0, Subscriber.first.favorite_nonprofits.count
  end

  test "removing a favorite" do
    @subscriber.favorite_nonprofits << @nonprofit
    delete :destroy, subscriber_guid: @subscriber.guid, id: @nonprofit.id

    assert_redirected_to subscriber_favorites_path(@subscriber.guid)
    assert_equal 0, Subscriber.first.favorite_nonprofits.count
    assert flash[:notice] =~ /removed/
  end

  test "removing a non-favorited nonprofit" do
    delete :destroy, subscriber_guid: @subscriber.guid, id: @nonprofit.id

    assert_redirected_to subscriber_favorites_path(@subscriber.guid)
    assert_equal 0, Subscriber.first.favorite_nonprofits.count
  end

end
