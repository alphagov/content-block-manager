Rswag::Api.configure do |c|
  c.openapi_root = Rails.root.join("engines/api/swagger").to_s
end
