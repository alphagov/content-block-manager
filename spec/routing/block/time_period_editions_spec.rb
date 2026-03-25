require "spec_helper"

RSpec.describe "Block::TimePeriodEditions routing", type: :routing do
  describe "routes to Block::TimePeriodEditionsController" do
    it "routes GET /block/time_period_editions/new to #new" do
      expect(get: "/block/time_period_editions/new").to route_to(
        controller: "block/time_period_editions",
        action: "new",
      )
    end

    it "routes POST /block/time_period_editions to #create" do
      expect(post: "/block/time_period_editions").to route_to(
        controller: "block/time_period_editions",
        action: "create",
      )
    end

    it "routes GET /block/time_period_editions/:id to #show" do
      expect(get: "/block/time_period_editions/1").to route_to(
        controller: "block/time_period_editions",
        action: "show",
        id: "1",
      )
    end

    it "routes GET /block/time_period_editions/:id/edit to #edit" do
      expect(get: "/block/time_period_editions/1/edit").to route_to(
        controller: "block/time_period_editions",
        action: "edit",
        id: "1",
      )
    end

    it "routes PATCH /block/time_period_editions/:id to #update" do
      expect(patch: "/block/time_period_editions/1").to route_to(
        controller: "block/time_period_editions",
        action: "update",
        id: "1",
      )
    end

    it "routes PUT /block/time_period_editions/:id to #update" do
      expect(put: "/block/time_period_editions/1").to route_to(
        controller: "block/time_period_editions",
        action: "update",
        id: "1",
      )
    end
  end

  describe "named route helpers" do
    it "generates new_block_time_period_edition_path" do
      expect(new_block_time_period_edition_path).to eq("/block/time_period_editions/new")
    end

    it "generates block_time_period_editions_path" do
      expect(block_time_period_editions_path).to eq("/block/time_period_editions")
    end

    it "generates block_time_period_edition_path with id" do
      expect(block_time_period_edition_path(1)).to eq("/block/time_period_editions/1")
    end

    it "generates edit_block_time_period_edition_path with id" do
      expect(edit_block_time_period_edition_path(1)).to eq("/block/time_period_editions/1/edit")
    end
  end
end
