module CapybaraPage
  def page
    Capybara.string(response.body)
  end
end

RSpec.configure do |config|
  config.include CapybaraPage, type: :request
end
