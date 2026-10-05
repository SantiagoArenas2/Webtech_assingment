class PagesController < ApplicationController
  def home
    @featured_rooms = Room.published
                           .includes(property: :neighborhood)
                           .order(created_at: :desc)
                           .limit(3)
  end
end
