# db/seeds.rb
require 'open-uri'
require 'faker'

puts "Updating existing users..."
User.find_each do |user|
  user.update(name: Faker::Name.name) if user.name.nil?

  unless user.profile_photo.attached?
    safe_name = user.name.gsub(/\s+/, "_").downcase
    profile_photo = URI.open("https://picsum.photos/300/300?random=#{rand(1..1000)}")
    user.profile_photo.attach(
      io: profile_photo,
      filename: "#{safe_name}.jpg",
      content_type: 'image/jpeg'
    )
  end
end

puts "Creating a new seller..."
seller = User.create!(
  name: Faker::Name.name,
  email: Faker::Internet.unique.email,
  password: "password"
)

# Attach seller profile photo
safe_seller_name = seller.name.gsub(/\s+/, "_").downcase
profile_photo = URI.open("https://picsum.photos/300/300?random=#{rand(1..1000)}")
seller.profile_photo.attach(
  io: profile_photo,
  filename: "#{safe_seller_name}.jpg",
  content_type: 'image/jpeg'
)

puts "Creating 6 products for the seller..."
products = 6.times.map do
  {
    title: [Faker::Commerce.product_name, ["Template", "Wallpaper", "Kit"].sample].join(" "),
    description: Faker::Lorem.paragraphs(number: 4).join("<br/><br/>"),
    price: Faker::Commerce.price
  }
end
products = seller.products.create!(products)

puts "Attaching product images..."
products.each do |product|
  3.times do |i|
    image = URI.open("https://picsum.photos/300/300?random=#{rand(1..1000)}")
    product.images.attach(
      io: image,
      filename: "#{product.title.parameterize}_#{i + 1}.jpg",
      content_type: 'image/jpeg'
    )
  end
end

puts "Seeding completed successfully!"
