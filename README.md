# Roomies

Room rental platform built with Rails 8, PostgreSQL, Bootstrap, Active Storage, and Action Text.
This repository contains the work for Assignments 1–4, including listing search, applications,
visits, reviews, authentication, authorization, and a public listings API.

## Team

- Santiago Arenas

## Repository structure

```text
.
├── index.html
├── styles.css
├── user-stories.md
├── domain-model.dbml
├── design-decisions.md
├── app/
├── db/
│   ├── migrate/
│   └── seeds.rb
├── config/
│   └── routes.rb
└── README.md
```

## Domain model

<img width="1440" height="720" alt="dbmodelo" src="https://github.com/user-attachments/assets/6db0a5ec-2a25-428c-bfe8-d0ed9e40dd02" />

## Running locally

```sh
bundle install
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
bin/dev
```

`bin/dev` starts Rails and the CSS build watcher. Open `http://localhost:3000`.
Active Storage keeps listing photographs on the configured local disk service. Photo uploads
accept PNG, JPEG, WebP, or GIF files up to 10 MB. Image variants require libvips.

Password reset instructions and new-application notifications are queued with Active Job using
`deliver_later`. Configure Action Mailer SMTP settings in the deployment environment to deliver
messages outside development/test.

## Demo accounts

`bin/rails db:seed` creates the following accounts. The demo password for all is `Roomies123!`.

| Role | Email | Demo use |
|---|---|---|
| Member | `camila.reyes@example.com` | Host with multiple properties and listings |
| Member | `valentina.soto@example.com` | Seeker with applications and a saved listing |
| Moderator | `francisca.vidal@example.com` | Can edit any property/listing, resolve reports, and manage neighborhoods/amenities |

Members can publish properties and listings, apply to other members' published listings, manage
their own listings and applications, propose/cancel visits as a host or applicant, and review
only visits they completed. Moderators can edit all properties/listings, see all applications,
delete any review, resolve reports, and manage neighborhoods/amenities. Visitors (not signed in)
can browse/search published listings, properties, and reviews; they cannot perform member or
moderator actions.

The seed data includes a draft listing on Camila's property: it is visible to Camila and the
moderator, but not to other members or visitors.

## Public JSON API — v1

All endpoints are public and return published listings only. Responses contain listing/property
attributes needed for search and deliberately exclude host names, email addresses, contact
details, addresses, applications, and other personal data.

### `GET /api/v1/listings`

Returns a JSON object with `data` (listing records) and `meta` (`total`, `limit`; maximum 100
records). Optional filters can be combined:

| Query parameter | Meaning |
|---|---|
| `neighborhood_id` | Filter by neighborhood ID |
| `max_rent` | Maximum monthly price |
| `available_from` | Return listings available on or before an ISO 8601 date, e.g. `2026-12-01` |
| `minimum_bedrooms` | Minimum property bedroom count |

Example:

```sh
curl "http://localhost:3000/api/v1/listings?max_rent=350000&available_from=2026-12-01"
```

Each record contains `id`, `label`, `price`, `deposit`, `available_from`,
`minimum_stay_months`, `furnished`, `private_bathroom`, `neighborhood`, `bedrooms`, and
`bathrooms`, plus the first public `photo_url` when a listing has one.

### `GET /api/v1/listings/:id`

Returns `{ "data": { ...listing fields..., "description": "...", "house_rules": "..." } }`.
Only published listings are addressable. An unknown or unpublished listing returns `404`.

Invalid filters return `400` with `{ "error": "One or more filters are invalid." }`.
The Listings search page consumes the index endpoint with `fetch`.

## Authentication

Sign up, sign in/out, reset a password by email, and edit your profile from the navigation bar.
Passwords are stored as secure password digests. Session and authorization failures are handled
with a user-facing message; role or ownership checks are enforced server-side with Pundit.

## Course

Web Technologies — 2026
