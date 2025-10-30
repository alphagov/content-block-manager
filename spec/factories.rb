[
  Dir[Rails.root.join("spec/factories/*.rb")],
].flatten.sort.each { |f| require f }
