RSpec.describe "Block::TimePeriods routing", type: :routing do
  describe "routes to Block::TimePeriodsController" do
    it "routes GET /block/time_periods/new to #new" do
      expect(get: "/block/time_periods/new").to route_to(
        controller: "block/time_periods",
        action: "new",
      )
    end

    it "routes POST /block/time_periods to #create" do
      expect(post: "/block/time_periods").to route_to(
        controller: "block/time_periods",
        action: "create",
      )
    end

    it "routes GET /block/time_periods/:id to #show" do
      expect(get: "/block/time_periods/123").to route_to(
        controller: "block/time_periods",
        action: "show",
        id: "123",
      )
    end

    it "routes GET /block/time_periods/:id/edit to #edit" do
      expect(get: "/block/time_periods/123/edit").to route_to(
        controller: "block/time_periods",
        action: "edit",
        id: "123",
      )
    end

    it "routes PATCH /block/time_periods/:id to #update" do
      expect(patch: "/block/time_periods/123").to route_to(
        controller: "block/time_periods",
        action: "update",
        id: "123",
      )
    end

    it "routes PUT /block/time_periods/:id to #update" do
      expect(put: "/block/time_periods/123").to route_to(
        controller: "block/time_periods",
        action: "update",
        id: "123",
      )
    end
  end

  describe "named route helpers" do
    it "generates new_block_time_period_path" do
      expect(new_block_time_period_path).to eq("/block/time_periods/new")
    end

    it "generates block_time_periods_path" do
      expect(block_time_periods_path).to eq("/block/time_periods")
    end

    it "generates block_time_period_path with id" do
      expect(block_time_period_path(123)).to eq("/block/time_periods/123")
    end

    it "generates edit_block_time_period_path with id" do
      expect(edit_block_time_period_path(123)).to eq("/block/time_periods/123/edit")
    end
  end
end
