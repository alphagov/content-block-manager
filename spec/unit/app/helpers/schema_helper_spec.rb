RSpec.describe SchemaHelper, type: :helper do
  include Rails.application.routes.url_helpers

  describe "classes_for_subschema_listing_heading(subschema)" do
    let(:relationship_type_predicate) do
      double("relationship type predicate", one_to_many?: double)
    end

    let(:subschema) { double("subschema", relationship_type: relationship_type_predicate) }

    context "when the subschema is in a 1:1 relationship with its parent schema" do
      before do
        allow(relationship_type_predicate).to receive(:one_to_many?).and_return(false)
      end

      it "returns no special styling classes" do
        expect(classes_for_subschema_listing_heading(subschema)).to be_blank
      end
    end

    context "when the subschema is in a one-to-many relationship with its parent schema" do
      before do
        allow(relationship_type_predicate).to receive(:one_to_many?).and_return(true)
      end

      it "returns a special styling class suited to more deeply nested objects" do
        expect(classes_for_subschema_listing_heading(subschema)).to eq("subschema-listing__heading")
      end
    end
  end

  describe "#redirect_url_for_subschema" do
    let(:edition) { build_stubbed(:edition, :contact) }
    let(:subschema) { double(:subschema, group:, id: "my_subschema") }

    context "when the subschema has a group" do
      let(:group) { nil }

      it "should generate a url with the subschema's step" do
        expect(workflow_path(edition, { step: "#{Workflow::Step::SUBSCHEMA_PREFIX}#{subschema.id}" })).to eq(redirect_url_for_subschema(subschema, edition))
      end
    end

    context "when the subschema has no group" do
      let(:group) { "some_group" }

      it "should generate a url with the subschema's group" do
        expect(workflow_path(edition, { step: "#{Workflow::Step::GROUP_PREFIX}#{subschema.group}" })).to eq(redirect_url_for_subschema(subschema, edition))
      end
    end
  end

  describe "#valid_schemas" do
    let(:user) { build(:user) }
    let(:user_can_view_all_content_block_types?) { false }

    let(:live_schemas) { 2.times.map { double("schema") } }
    let(:alpha_schemas) { 3.times.map { double("schema") } }

    let(:all_schemas) { live_schemas + alpha_schemas }

    before do
      allow(Schema).to receive(:live).and_return(live_schemas)
      allow(Schema).to receive(:all).and_return(all_schemas)

      allow(Current).to receive(:user).and_return(user)
      allow(user).to receive(:has_permission?)
                       .with(User::Permissions::SHOW_ALL_CONTENT_BLOCK_TYPES)
                       .and_return(user_can_view_all_content_block_types?)

      allow(Flipflop).to receive(:show_all_content_block_types?).and_return(show_all_content_block_types_feature_flag_is_on?)
    end

    describe "when the show_all_content_block_types feature flag is turned on" do
      let(:show_all_content_block_types_feature_flag_is_on?) { true }

      it "returns all of the schemas" do
        expect(valid_schemas).to eq(all_schemas)
      end
    end

    describe "when the show_all_content_block_types feature flag is turned off" do
      let(:show_all_content_block_types_feature_flag_is_on?) { false }

      it "only returns the live schemas" do
        expect(valid_schemas).to eq(live_schemas)
      end

      describe "when the current user has the show_all_content_block_types permission" do
        let(:user_can_view_all_content_block_types?) { true }

        it "returns all of the schemas" do
          expect(valid_schemas).to eq(all_schemas)
        end
      end
    end
  end
end
