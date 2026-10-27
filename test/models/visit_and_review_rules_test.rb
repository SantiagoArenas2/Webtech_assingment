require "test_helper"

class VisitAndReviewRulesTest < ActiveSupport::TestCase
  setup do
    @host = create_user("host")
    @seeker = create_user("seeker")
    neighborhood = Neighborhood.create!(name: "Test neighborhood")
    @property = Property.create!(
      host: @host, neighborhood: neighborhood, address: "1 Test Street",
      description: "A shared home."
    )
    room = Room.create!(property: @property, label: "Sunny room", price: 100_000,
                        available_from: Date.current)
    room.publish!
    @application = Application.create!(
      room: room, seeker: @seeker, message: "I am interested.",
      move_in_date: Date.current + 1.day, intended_stay_months: 6
    )
  end

  test "a visit requires a shortlisted application and a future schedule" do
    visit = @application.build_visit(scheduled_at: 1.day.from_now)
    assert_not visit.valid?

    @application.update!(status: :shortlisted)
    visit.scheduled_at = 1.day.ago
    assert_not visit.valid?

    visit.scheduled_at = 1.day.from_now
    assert visit.valid?
  end

  test "only a completed visit by its applicant enables a review" do
    @application.update!(status: :shortlisted)
    visit = @application.create_visit!(scheduled_at: 1.day.from_now)
    review = Review.new(property: @property, author: @seeker, visit: visit, rating: 5)
    assert_not review.valid?

    visit.update!(status: :confirmed)
    visit.update!(status: :completed, scheduled_at: 1.day.ago)
    assert review.valid?
  end

  private

  def create_user(name)
    User.create!(name: name, email: "#{name}@example.test", password_hash: "test")
  end
end
