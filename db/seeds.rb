return if Rails.env.test?

User.create!(
  name: "Test user",
  uid: "test-user-1",
  email: "test@gds.example.com",
  permissions: ["signin", "GDS Admin", "GDS Editor", "Managing Editor", "Sidekiq Admin"],
)
