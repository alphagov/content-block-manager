[
  Dir[Rails.root.join("spec/factories/*.rb")],
  Dir[Rails.root.join("engines/**/spec/factories/*.rb")],
].flatten.sort.each { |f| require f }
