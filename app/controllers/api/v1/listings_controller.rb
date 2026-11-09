module Api
  module V1
    class ListingsController < ApplicationController
      allow_unauthenticated_access

      def index
        authorize Room, :index?
        rooms = policy_scope(Room).published.includes(:room_photos, property: :neighborhood)
        rooms = rooms.joins(:property).where(properties: { neighborhood_id: integer_filter(:neighborhood_id) }) if params[:neighborhood_id].present?
        rooms = rooms.where("rooms.price <= ?", decimal_filter(:max_rent)) if params[:max_rent].present?
        rooms = rooms.where("rooms.available_from <= ?", date_filter(:available_from)) if params[:available_from].present?
        rooms = rooms.joins(:property).where("properties.bedrooms >= ?", integer_filter(:minimum_bedrooms)) if params[:minimum_bedrooms].present?

        total = rooms.count
        render json: { data: rooms.order(created_at: :desc).limit(100).map { |room| listing_json(room) },
                       meta: { total: total, limit: 100 } }
      rescue ArgumentError
        render json: { error: "One or more filters are invalid." }, status: :bad_request
      end

      def show
        @room = policy_scope(Room).published.includes(:room_photos, property: :neighborhood).find_by(id: params[:id])
        return render json: { error: "Listing not found." }, status: :not_found unless @room

        authorize @room
        render json: { data: listing_json(@room).merge(
          description: @room.description.to_plain_text,
          house_rules: @room.house_rules.to_plain_text
        ) }
      end

      private

      def integer_filter(key)
        value = Integer(params[key], 10)
        raise ArgumentError unless value.positive?

        value
      end

      def decimal_filter(key)
        value = params[key].to_s
        raise ArgumentError unless value.match?(/\A\d{1,8}(?:\.\d{1,2})?\z/)

        BigDecimal(value)
      end

      def date_filter(key)
        Date.iso8601(params[key])
      end

      def listing_json(room)
        {
          id: room.id,
          label: room.label,
          price: room.price,
          deposit: room.deposit,
          available_from: room.available_from.iso8601,
          minimum_stay_months: room.minimum_stay_months,
          furnished: room.furnished?,
          private_bathroom: room.private_bathroom?,
          neighborhood: room.property.neighborhood.name,
          bedrooms: room.property.bedrooms,
          bathrooms: room.property.bathrooms,
          photo_url: room.room_photos.first&.url
        }
      end
    end
  end
end
