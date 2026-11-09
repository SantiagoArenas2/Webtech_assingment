require "test_helper"

class AuthenticationAndAuthorizationTest < ActionDispatch::IntegrationTest
  setup do
    @host = create_user("host@example.test")
    @seeker = create_user("seeker@example.test")
    @other_member = create_user("other@example.test")
    @moderator = create_user("moderator@example.test", role: :moderator)
    neighborhood = Neighborhood.create!(name: "Test neighborhood")
    @property = Property.create!(
      host: @host, neighborhood: neighborhood, address: "1 Test Street",
      description: "A shared home."
    )
    @room = Room.create!(
      property: @property, label: "Sunny room", price: 100_000,
      available_from: Date.current
    )
    @room.publish!
    @application = Application.create!(
      room: @room, seeker: @seeker, message: "I am interested.",
      move_in_date: Date.current + 1.day, intended_stay_months: 6
    )
  end

  test "visitors can browse published listings but cannot access applications" do
    get listings_path
    assert_response :success

    get listing_path(@room)
    assert_response :success

    get applications_path
    assert_redirected_to new_session_path
    follow_redirect!
    assert_match "Please sign in to continue", response.body
  end

  test "application ids are visible only to the seeker, host, and moderator" do
    sign_in_as(@seeker)
    get application_path(@application)
    assert_response :success

    sign_in_as(@other_member)
    get application_path(@application)
    assert_redirected_to root_path
    follow_redirect!
    assert_match "not allowed", response.body

    sign_in_as(@moderator)
    get application_path(@application)
    assert_response :success
  end

  test "public API returns listing data without personal or address fields" do
    get api_v1_listings_path, as: :json
    assert_response :success

    listing = response.parsed_body.fetch("data").first
    assert_equal @room.id, listing.fetch("id")
    assert_equal "Test neighborhood", listing.fetch("neighborhood")
    assert_not listing.key?("host")
    assert_not listing.key?("email")
    assert_not listing.key?("address")
  end

  test "signup creates a member account" do
    post registrations_path, params: {
      user: {
        name: "New Member", email: "new@example.test",
        password: "Roomies123!", password_confirmation: "Roomies123!"
      }
    }

    assert_redirected_to root_path
    assert User.find_by!(email: "new@example.test").member?
  end

  private

  def create_user(email, role: :member)
    User.create!(name: email.split("@").first, email: email, password: "Roomies123!", role: role)
  end

  def sign_in_as(user)
    post session_path, params: { email: user.email, password: "Roomies123!" }
    assert_response :redirect
  end
end
