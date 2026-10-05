# Roomies

Room rental platform — Assignment 1 (user stories, domain model, landing page) and
Assignment 2 (Rails application, models, and read-only views).

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

This app uses Rails 8, PostgreSQL, and Bootstrap via `cssbundling-rails`.

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
