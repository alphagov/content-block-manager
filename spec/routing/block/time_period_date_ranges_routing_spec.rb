RSpec.describe "Block::TimePeriodDateRanges routing", type: :routing do
  describe "routes to Block::TimePeriodDateRangesController" do
    it "routes GET /block/documents/:document_id/time-period-date-ranges/:id to #show" do
      expect(get: "/block/documents/456/time-period-date-ranges/123").to route_to(
        controller: "block/time_period_date_ranges",
        action: "show",
        document_id: "456",
        id: "123",
      )
    end

    it "routes GET /block/documents/:document_id/time-period-date-ranges/:id/edit to #edit" do
      expect(get: "/block/documents/456/time-period-date-ranges/123/edit").to route_to(
        controller: "block/time_period_date_ranges",
        action: "edit",
        document_id: "456",
        id: "123",
      )
    end

    it "routes PATCH /block/documents/:document_id/time-period-date-ranges/:id to #update" do
      expect(patch: "/block/documents/456/time-period-date-ranges/123").to route_to(
        controller: "block/time_period_date_ranges",
        action: "update",
        document_id: "456",
        id: "123",
      )
    end

    it "routes PUT /block/documents/:document_id/time-period-date-ranges/:id to #update" do
      expect(put: "/block/documents/456/time-period-date-ranges/123").to route_to(
        controller: "block/time_period_date_ranges",
        action: "update",
        document_id: "456",
        id: "123",
      )
    end
  end

  describe "named route helpers" do
    it "generates block_document_time_period_date_range_path with ids" do
      expect(block_document_time_period_date_range_path(456, 123)).to eq(
        "/block/documents/456/time-period-date-ranges/123",
      )
    end

    it "generates edit_block_document_time_period_date_range_path with ids" do
      expect(edit_block_document_time_period_date_range_path(456, 123)).to eq(
        "/block/documents/456/time-period-date-ranges/123/edit",
      )
    end
  end
end
