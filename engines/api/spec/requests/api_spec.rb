require "swagger_helper"

RSpec.describe "API" do
  path "/blocks/search" do
    get "Search content blocks" do
      tags "Content Blocks"
      produces "application/json"

      response "200", "blocks found" do
        run_test!
      end
    end
  end
end
