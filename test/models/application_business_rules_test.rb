require "test_helper"

class ApplicationBusinessRulesTest < ActiveSupport::TestCase
  setup do
    @host = build_user("host")
    @seeker = build_user("seeker")
    @other_seeker = build_user("other")
    neighborhood = Neighborhood.create!(name: "Test neighborhood")
    property = Property.create!(
      host: @host, neighborhood: neighborhood, address: "1 Test Street",
      description: "A shared home."
    )
    @room = Room.create!(
      property: property, label: "Sunny room", price: 100_000,
      available_from: Date.current
    )
  end

  test "new applications require a published listing and cannot be from its host" do
    assert_not build_application(@seeker).valid?
    assert_not build_application(@host).valid?

    @room.publish!
    assert build_application(@seeker).valid?
    assert_not build_application(@host).valid?
  end

  test "a seeker cannot apply twice to the same listing" do
    @room.publish!
    create_application(@seeker)

    assert_not build_application(@seeker).valid?
  end

  test "acceptance rejects competing applicants and reserves the listing" do
    @room.publish!
    selected = create_application(@seeker)
    competing = create_application(@other_seeker)

    selected.accept!

    assert selected.reload.accepted?
    assert competing.reload.rejected?
    assert @room.reload.reserved?
  end

  test "acceptance rolls back all changes when reserving the listing fails" do
    @room.publish!
    selected = create_application(@seeker)
    competing = create_application(@other_seeker)
    @room.update_column(:price, 0)

    assert_raises(ActiveRecord::RecordInvalid) { selected.accept! }

    assert selected.reload.pending?
    assert competing.reload.pending?
    assert @room.reload.published?
  end

  private

  def build_user(name)
    User.create!(name: name, email: "#{name}@example.test", password_hash: "test")
  end

  def build_application(seeker)
    Application.new(
      room: @room, seeker: seeker, message: "I am interested.",
      move_in_date: Date.current + 1.day, intended_stay_months: 6
    )
  end

  def create_application(seeker)
    build_application(seeker).tap(&:save!)
  end
end
