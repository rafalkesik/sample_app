# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# USERS
# Create a main sample user.
User.create!(name:  "Example User",
              email: "example@railstutorial.org",
              password:              "foobar",
              password_confirmation: "foobar",
              admin: true,
              activated:    true,
              activated_at: Time.zone.now)

# Generate a bunch of additional users.
99.times do |n|
    name = Faker::Name.name
    email = "example-#{n+1}@railstutorial.org"
    password = "password"
    User.create!(name:  name,
                  email: email,
                  password:              password,
                  password_confirmation: password,
                  activated:    true,
                  activated_at: Time.zone.now)
end

# MICROPOSTS
# Generate microposts for a subset of users.
users = User.order(:created_at).take(6)
50.times do
    content = Faker::ChuckNorris.fact
    while content.length > 140 do
        content = Faker::ChuckNorris.fact
    end
    users.each { |user| user.microposts.create!(content: content)}
end

# FOLLOW RELATIONSHIPS
# Generate following relationships
users = User.all
user = users.first
following = users[2..50]
followers  = users[3..40]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }
