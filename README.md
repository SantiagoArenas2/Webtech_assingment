# Roomies

Room rental platform — Assignments 1–3 (domain design, read-only Rails views, and CRUD workflows).

## Team

- Santiago Arenas

## Repository structure

```
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



## Running the Rails app

This app uses Rails 8, PostgreSQL, and Bootstrap via `cssbundling-rails`. Image
variants use the `image_processing` dependency configured in the Gemfile.

## Assignment 3 setup

Active Storage stores photographs on the configured local disk service. Action Text
stores listing descriptions and house rules. Run `bin/rails db:migrate` after updating
the code; `bin/rails db:seed` loads the sample users and listings. Photo uploads accept
PNG, JPEG, WebP, and GIF files up to **10 MB per photograph**. Image variants use the
`image_processing` gem and libvips (included in the production Docker image); install
libvips on a local development machine before requesting image variants.

There is no authentication yet. Choose the acting user from the navigation bar; that
user is used as the author/seeker/host for actions.

To set it up locally:

```
bundle install
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
bin/dev
```

`bin/dev` starts both the Rails server and the CSS build watcher — the app will not look right if you
start it with `bin/rails server` alone. Visit `http://localhost:3000` once it's running.

## Course

Web Technologies — 2026
