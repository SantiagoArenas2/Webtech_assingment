puts "Clearing existing data..."
[Report, SavedListing, Visit, Application, Review, RoomPhoto, Room,
 PropertyAmenity, Property, Amenity, Neighborhood, User].each(&:delete_all)

puts "Creating neighborhoods..."
neighborhoods = %w[Ñuñoa Providencia Independencia San\ Miguel Estación\ Central].map do |name|
  Neighborhood.create!(name: name)
end
nunoa, providencia, independencia, san_miguel, estacion_central = neighborhoods

puts "Creating amenities..."
amenities = ["Wifi", "Private bathroom", "Washing machine", "Furnished", "Heating", "Parking"].map do |name|
  Amenity.create!(name: name)
end
wifi, private_bathroom, washing_machine, furnished, heating, parking = amenities

puts "Creating users..."
hosts = [
  User.create!(name: "Camila Reyes", email: "camila.reyes@example.com", password_hash: "hashed-pw-1"),
  User.create!(name: "Jorge Muñoz", email: "jorge.munoz@example.com", password_hash: "hashed-pw-2")
]

seekers = [
  User.create!(name: "Valentina Soto", email: "valentina.soto@example.com", password_hash: "hashed-pw-3"),
  User.create!(name: "Diego Fuentes", email: "diego.fuentes@example.com", password_hash: "hashed-pw-4"),
  User.create!(name: "Martina Rojas", email: "martina.rojas@example.com", password_hash: "hashed-pw-5"),
  User.create!(name: "Benjamín Castro", email: "benjamin.castro@example.com", password_hash: "hashed-pw-6")
]

moderator = User.create!(
  name: "Francisca Vidal",
  email: "francisca.vidal@example.com",
  password_hash: "hashed-pw-7",
  is_moderator: true
)

camila, jorge = hosts
valentina, diego, martina, benjamin = seekers

puts "Creating properties..."
property_a = Property.create!(
  host: camila,
  neighborhood: nunoa,
  address: "Av. Irarrázaval 2450, Ñuñoa",
  description: "Casa compartida de tres pisos cerca del metro Ñuñoa, con patio común y buena luz natural."
)
[wifi, washing_machine, heating].each { |a| PropertyAmenity.create!(property: property_a, amenity: a) }

property_b = Property.create!(
  host: camila,
  neighborhood: providencia,
  address: "Bustamante 180, Providencia",
  description: "Departamento moderno a dos cuadras del parque, con portería 24/7."
)
[wifi, private_bathroom, parking].each { |a| PropertyAmenity.create!(property: property_b, amenity: a) }

property_c = Property.create!(
  host: jorge,
  neighborhood: san_miguel,
  address: "Gran Avenida 4810, San Miguel",
  description: "Casa familiar con piezas amobladas, ambiente tranquilo, cerca de la línea 2 de metro."
)
[wifi, furnished, washing_machine].each { |a| PropertyAmenity.create!(property: property_c, amenity: a) }

property_d = Property.create!(
  host: jorge,
  neighborhood: independencia,
  address: "Av. Independencia 1920, Independencia",
  description: "Departamento pequeño, ideal para estudiantes de la Facultad de Medicina cercana."
)
[wifi, heating].each { |a| PropertyAmenity.create!(property: property_d, amenity: a) }

puts "Creating rooms..."
room_a1 = Room.create!(
  property: property_a, label: "Room 1 — upstairs", price: 280_000, deposit: 280_000,
  minimum_stay_months: 6, available_from: Date.current + 5.days, status: "available",
  description: "Pieza individual con escritorio, ventana hacia el patio."
)
room_a2 = Room.create!(
  property: property_a, label: "Room 2 — ground floor", price: 250_000, deposit: 250_000,
  minimum_stay_months: 3, available_from: Date.current + 20.days, status: "available",
  description: "Pieza más pequeña, acceso directo al living compartido."
)
room_b1 = Room.create!(
  property: property_b, label: "Main bedroom", price: 380_000, deposit: 380_000,
  minimum_stay_months: 12, available_from: Date.current, status: "rented",
  description: "Pieza principal con baño privado y balcón."
)
room_c1 = Room.create!(
  property: property_c, label: "Room facing the street", price: 230_000, deposit: 230_000,
  minimum_stay_months: 3, available_from: Date.current + 10.days, status: "available",
  description: "Pieza amoblada con cama de plaza y media y clóset."
)
room_c2 = Room.create!(
  property: property_c, label: "Back room", price: 210_000, deposit: 210_000,
  minimum_stay_months: 3, available_from: Date.current + 15.days, status: "inactive",
  description: "Pieza en remodelación, vuelve a estar disponible el próximo mes."
)
room_d1 = Room.create!(
  property: property_d, label: "Studio room", price: 260_000, deposit: 260_000,
  minimum_stay_months: 6, available_from: Date.current + 1.day, status: "available",
  description: "Pieza con calefacción central, ideal para quien estudia hasta tarde."
)

puts "Creating room photos..."
{
  room_a1 => ["https://picsum.photos/id/1080/600/420", "https://picsum.photos/id/1081/600/420"],
  room_a2 => ["https://picsum.photos/id/1082/600/420"],
  room_b1 => ["https://picsum.photos/id/1078/600/420"],
  room_c1 => ["https://picsum.photos/id/1048/600/420"],
  room_d1 => ["https://picsum.photos/id/1074/600/420"]
}.each do |room, urls|
  urls.each_with_index { |url, i| RoomPhoto.create!(room: room, url: url, sort_order: i) }
end

puts "Creating applications (competing applicants, every status)..."
app_1 = Application.create!(room: room_a1, seeker: valentina, message: "Hola! Me interesa mucho la pieza, soy estudiante de ingeniería y busco algo tranquilo.", status: "shortlisted")
app_2 = Application.create!(room: room_a1, seeker: diego, message: "Buenas, vivo cerca y necesito mudarme pronto, ¿podríamos coordinar una visita?", status: "submitted")

app_3 = Application.create!(room: room_b1, seeker: martina, message: "Hola, me encantó el depa, quedo atenta.", status: "accepted")
app_4 = Application.create!(room: room_b1, seeker: benjamin, message: "Hola, también estoy interesado si no resulta con el otro postulante.", status: "rejected")

app_5 = Application.create!(room: room_c1, seeker: valentina, message: "Me interesa esta pieza también, está más cerca de mi trabajo.", status: "withdrawn")

app_6 = Application.create!(room: room_d1, seeker: diego, message: "Hola, vi la pieza y me gustaría agendar una visita esta semana.", status: "submitted")

puts "Creating visits..."
Visit.create!(application: app_1, scheduled_at: app_1.created_at + 2.days, status: "scheduled")
Visit.create!(application: app_3, scheduled_at: app_3.created_at + 1.day, status: "completed")

puts "Creating reviews..."
Review.create!(property: property_a, author: martina, rating: 5, comment: "Excelente ubicación y la host siempre respondió rápido. Muy recomendable.")
Review.create!(property: property_a, author: benjamin, rating: 4, comment: "Buena pieza, el único detalle es que el wifi a veces es lento en el segundo piso.")
Review.create!(property: property_c, author: valentina, rating: 3, comment: "Está bien para el precio, pero la pieza es más chica de lo que parecía en las fotos.")

puts "Creating saved listings..."
SavedListing.create!(seeker: valentina, room: room_c1)
SavedListing.create!(seeker: valentina, room: room_d1)
SavedListing.create!(seeker: diego, room: room_a1)

puts "Creating reports..."
Report.create!(
  room: room_c2, reporter: benjamin, reason: "El anuncio dice disponible pero lleva semanas en mantención, parece abandonado.",
  status: "pending"
)
Report.create!(
  room: room_a2, reporter: martina, reason: "El precio publicado no coincide con lo que me cobraron al preguntar.",
  status: "dismissed", resolver: moderator, resolved_at: Time.current - 1.day
)

puts "Seed complete:"
puts "  Users: #{User.count} (#{User.moderators.count} moderator)"
puts "  Neighborhoods: #{Neighborhood.count}"
puts "  Amenities: #{Amenity.count}"
puts "  Properties: #{Property.count}"
puts "  Rooms: #{Room.count} (#{Room.published.count} published)"
puts "  Applications: #{Application.count}"
puts "  Visits: #{Visit.count}"
puts "  Reviews: #{Review.count}"
puts "  Saved listings: #{SavedListing.count}"
puts "  Reports: #{Report.count}"
