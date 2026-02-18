require "capybara/rails"

RSpec.describe "EmbeddedObjectController requests", type: :request do
  include Rails.application.routes.url_helpers

  let(:organisation) { build(:organisation) }

  let(:current_step) { instance_double(Workflow::Step, name: :embedded_date_range) }
  let(:next_step) { instance_double(Workflow::Step, name: :next_step) }

  let(:steps) do
    [
      current_step,
      next_step,
    ]
  end

  before do
    logout
    user = create(:user)
    login_as(user)

    allow(Organisation).to receive(:all).and_return([organisation])
    allow(Workflow::Steps).to receive(:for).and_return(steps)
  end

  context "when the subschema is in a 1:1 relationship with the parent schema" do
    let(:edition) do
      create(:edition,
             :time_period,
             details: {
               "description" => "Tax year",
             })
    end

    let(:parent_schema) { double(:schema, id: "content_block_time_period", block_type: "time_period") }
    let(:subschema_id) { "date_range" }

    let(:body) do
      {
        "type" => "object",
        "properties" => {
          "date_range" => {
            "type" => "object",
            "properties" => {
              "start" => {
                "type" => "object",
                "properties" => {
                  "date" => { "type" => "string" },
                  "time" => { "type" => "string" },
                },
              },
              "end" => {
                "type" => "object",
                "properties" => {
                  "date" => { "type" => "string" },
                  "time" => { "type" => "string" },
                },
              },
            },
          },
        },
      }
    end

    let(:schema) { double("schema", body: [], name: "Schema") }

    let(:subschema) do
      Schema::EmbeddedSchema.new(subschema_id, body, parent_schema)
    end

    before do
      allow(Schema).to receive(:find_by_block_type).with(edition.document.block_type).and_return(schema)
      allow(schema).to receive(:subschema).with("date_range").and_return(subschema)
    end

    describe "#new" do
      it "sets the @subschema according to the given object_type" do
        get new_sole_embedded_object_edition_path(edition, :date_range)

        expect(assigns(:subschema)).to eq(subschema)
      end

      it "sets the @back_link to the edit_draft step" do
        get new_sole_embedded_object_edition_path(edition, :date_range)

        expect(assigns(:back_link)).to eq(workflow_path(edition, step: :edit_draft))
      end

      it "renders the 'new' template" do
        get new_sole_embedded_object_edition_path(edition, :date_range)

        expect(response).to render_template(:new)
      end
    end

    describe "#create" do
      let(:params) do
        {
          "edition" =>
            { "details" => {
              "date_range" => {
                "start" => { "date" => "2025-04-06", "time" => "00:00" },
                "end" => { "date" => "2026-04-05", "time" => "23:59" },
              },
            } },
          "id" => "123",
          "step" => "embedded_date_range",
        }
      end

      it "sets a flash confirming that the object has been saved (not inviting creation of further objects)" do
        post create_sole_embedded_object_edition_path(edition, object_type: :date_range),
             params: params

        expect(flash.[](:success)).to eq(
          I18n.t(
            "edition.create.embedded_object.created_confirmation",
            object_name: "Date range",
          ),
        )
      end

      it "redirects to the step which follows the given step param (according to Workflow::Steps)" do
        post create_sole_embedded_object_edition_path(edition, object_type: :date_range),
             params: params

        expect(response).to redirect_to(workflow_path(edition, step: "next_step"))
      end

      context "when the object being saved is invalid" do
        before do
          allow_any_instance_of(Edition).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
        end

        it "re-renders the 'new' template" do
          post create_sole_embedded_object_edition_path(edition, object_type: :date_range),
               params: params

          expect(response).to render_template(:new)
        end
      end
    end

    describe "#edit" do
      context "when the expected sole embedded object exists" do
        before do
          edition.details[:date_range] = {
            "start" => { "date" => "2025-04-06", "time" => "00:00" },
            "end" => { "date" => "2026-04-05", "time" => "23:52" },
          }
          edition.save!
        end

        it "sets the @subschema according to the given object_type" do
          get edit_sole_embedded_object_edition_path(edition, :date_range)

          expect(assigns(:subschema)).to eq(subschema)
        end

        it "sets the @redirect_url to the edit_draft step" do
          get edit_sole_embedded_object_edition_path(edition, :date_range)

          expect(assigns(:redirect_url)).to eq(workflow_path(edition, step: :review))
        end

        it "renders the 'new' template" do
          get edit_sole_embedded_object_edition_path(edition, :date_range)

          expect(response).to render_template(:edit)
        end
      end

      context "when the expected sole embedded object does NOT exist" do
        before do
          edition.details = { "title" => "Edition title" }
          edition.save!
        end

        it "renders the 'not found' template" do
          get edit_sole_embedded_object_edition_path(edition, :date_range)

          expect(response).to render_template("not_found")
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    describe "#update" do
      let(:params) do
        {
          "edition" =>
            { "details" => {
              "date_range" => {
                "start" => { "date" => "2025-04-06", "time" => "00:00" },
                "end" => { "date" => "2026-04-05", "time" => "23:59" },
              },
            } },
          "id" => "123",
          "step" => "embedded_date_range",
        }
      end

      it "sets a flash confirming that the object has been saved (not inviting creation of further objects)" do
        put sole_embedded_object_edition_path(edition, object_type: :date_range),
            params: params

        expect(flash.[](:success)).to eq(
          I18n.t(
            "edition.create.embedded_object.updated_confirmation",
            object_name: "Date range",
          ),
        )
      end

      it "sets the @redirect_url to the given url" do
        put sole_embedded_object_edition_path(
          edition,
          :date_range,
          redirect_url: "/redirect/to/path",
        ), params: params

        expect(assigns(:redirect_url)).to eq("/redirect/to/path")
      end

      it "redirects to the step which follows the given step param (according to Workflow::Steps)" do
        put sole_embedded_object_edition_path(edition, object_type: :date_range),
            params: params

        expect(response).to redirect_to(workflow_path(edition, step: "next_step"))
      end

      context "when the object being saved is invalid" do
        before do
          allow_any_instance_of(Edition).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
        end

        it "re-renders the 'edit' template" do
          put sole_embedded_object_edition_path(edition, object_type: :date_range),
              params: params

          expect(response).to render_template(:edit)
        end
      end
    end
  end
end
