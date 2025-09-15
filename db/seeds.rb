# db/seeds.rb
require 'faker'
require 'open-uri'

images_path = Rails.root.join("db/images")
image_files = Dir.children(images_path).select { |f| f.match?(/\.(jpg|jpeg|png)$/i) }

puts "Creating sellers and products..."

5.times do
  seller = User.create!(
    name: Faker::Name.name,
    email: Faker::Internet.unique.email,
    password: "password"
  )

  # Attach profile photo from RoboHash
  profile_photo = URI.open("https://robohash.org/#{seller.name.gsub(' ', '')}")
  seller.profile_photo.attach(
    io: profile_photo,
    filename: "#{seller.name.parameterize}.png",
    content_type: "image/png"
  )

  puts "→ Seller: #{seller.name}"

  # Create multiple products for this seller
  products = seller.products.create!(
    6.times.map do
      {
        title: [Faker::Commerce.product_name, ["wears"].sample].join(" "),
        description: Faker::Lorem.paragraphs(number: 4).join("<br/><br/>"),
        price: Faker::Commerce.price
      }
    end
  )

  # Attach multiple images to each product from db/seeds/images
  products.each do |product|
    3.times do |i|
      image_filename = image_files.sample
      image_path = File.join(images_path, image_filename)
      product.images.attach(
        io: File.open(image_path),
        filename: "#{product.title.parameterize}_#{i + 1}#{File.extname(image_filename)}",
        content_type: "image/#{File.extname(image_filename).delete('.')}"
      )
    end
    puts "  → Product: #{product.title} (3 images attached)"
  end
end

puts "✅ Seeding complete!"
