# Design Decisions — Roomies

## Entities introduced beyond the project description

- **`room_photos`**: the brief only mentions "a photo" per listing, but a real room listing needs several. Split into
  its own table (instead of a single `photo_url` column on `rooms`) so a room can have any number of photos, ordered
  by `sort_order`.
- **`property_amenities`**: a join table for the many-to-many relationship between `properties` and `amenities`.
  Not named in the brief, but required as soon as amenities are modeled as a reusable catalog instead of free text.
- **`visits`**: kept separate from `applications` instead of adding `visit_date` columns directly on `applications`.
  A visit can be rescheduled or cancelled independently of the application it belongs to, and an application could
  in principle have more than one visit attempt.
- **`saved_listings`**: the join table backing the "save a listing" story. Modeled as a many-to-many between
  `users` (as seeker) and `rooms`, with its own `created_at` so favorites can be sorted by recency.

## Listing lifecycle

A `room` moves through `status`: **available → rented → inactive**. It starts as `available` when the host
publishes it. It becomes `rented` the moment the host accepts an application for it (see below). A host can also
set it to `inactive` manually at any time (e.g. taking a break from renting), independent of applications.

## Application lifecycle

An `application` moves through `status`: **submitted → shortlisted → accepted / rejected**, with **withdrawn** as an
exit point the seeker can trigger from `submitted` or `shortlisted`. When a host accepts one application for a
room, all other non-withdrawn applications for that same room are moved to `rejected` and the room's status changes
to `rented`, as described in user story 12. We treat this as an application-side state transition rather than a
separate "closed" entity, since no new information needs to be recorded beyond the status change itself.

## Assumptions

- A `report` targets a `room`, not a `property`, since listings are browsed and reported at the room level; a
  report about the property itself (e.g. a fake address) is filed against one of its rooms.
- Only a `user` with `is_moderator = true` can resolve a `report` (accepted as the value of `resolved_by`); the
  brief doesn't specify whether moderators are a fully separate account type, and we assumed a flag on `users` is
  sufficient since nothing in the brief suggests a moderator can't also use the platform as a member.
- A `review` is tied to a `property`, not a `room`, since visits and stays are experienced at the property level
  (shared spaces, host responsiveness) even though the specific room being reviewed may no longer exist by the
  time the review is written.
- We assumed one `visit` can be scheduled per `application` at a time (not simultaneous visits), but a new visit
  row can be created if the previous one is cancelled and rescheduled.
