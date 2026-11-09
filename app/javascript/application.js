// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import * as bootstrap from "bootstrap"
import "trix"
import "@rails/actiontext"

const loadListings = async (form) => {
  const results = document.querySelector("#listing-results")
  const params = new URLSearchParams(new FormData(form))
  for (const [key, value] of [...params.entries()]) {
    if (!value) params.delete(key)
  }

  results.setAttribute("aria-busy", "true")
  try {
    const response = await fetch(`${form.dataset.apiUrl}?${params}`, {
      headers: { Accept: "application/json" }
    })
    if (!response.ok) throw new Error(`Listing search failed (${response.status}).`)

    const { data } = await response.json()
    results.replaceChildren()
    if (data.length === 0) {
      const empty = document.createElement("p")
      empty.className = "text-muted"
      empty.textContent = "No listings match your search."
      results.append(empty)
      return
    }

    const row = document.createElement("div")
    row.className = "row g-4"
    data.forEach((listing) => {
      const column = document.createElement("div")
      column.className = "col-md-4"
      const card = document.createElement("article")
      card.className = "listing-card"
      if (listing.photo_url && /^https?:\/\//i.test(listing.photo_url)) {
        const image = document.createElement("img")
        image.className = "listing-photo"
        image.src = listing.photo_url
        image.alt = `Photo of ${listing.label} in ${listing.neighborhood}`
        card.append(image)
      }
      const body = document.createElement("div")
      body.className = "listing-body"
      const neighborhood = document.createElement("p")
      neighborhood.className = "listing-neighborhood"
      neighborhood.textContent = listing.neighborhood
      const price = document.createElement("span")
      price.className = "listing-price"
      price.textContent = `${new Intl.NumberFormat(undefined, { style: "currency", currency: "CLP", maximumFractionDigits: 0 }).format(listing.price)} / month`
      const date = document.createElement("span")
      date.className = "listing-date"
      date.textContent = `Avail. ${new Date(`${listing.available_from}T00:00:00`).toLocaleDateString()}`
      const link = document.createElement("a")
      link.className = "stretched-link link-brand"
      link.href = `/listings/${encodeURIComponent(listing.id)}`
      link.textContent = "View details"
      body.append(neighborhood, price, date, link)
      card.append(body)
      column.append(card)
      row.append(column)
    })
    results.append(row)
  } catch (error) {
    results.replaceChildren()
    const failure = document.createElement("p")
    failure.className = "alert alert-danger"
    failure.textContent = "Listings could not be loaded. Please try again."
    results.append(failure)
    console.error(error)
  } finally {
    results.setAttribute("aria-busy", "false")
  }
}

document.addEventListener("turbo:load", () => {
  const form = document.querySelector("#listing-search")
  if (!form) return

  form.addEventListener("submit", (event) => {
    event.preventDefault()
    loadListings(form)
  })
  loadListings(form)
})
