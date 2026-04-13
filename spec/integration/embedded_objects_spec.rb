require "capybara/rails"

RSpec.describe "EmbeddedObjectsController requests", type: :request do
  include Rails.application.routes.url_helpers

  let(:organisation) { build(:organisation) }

  before do
    logout
    user = create(:user)
    login_as(user)

    allow(Organisation).to receive(:all).and_return([organisation])
  end

  let(:edition) do
    create(:edition,
           :pension,
           details: {
             "something" => {
               "embedded" => { "title" => "Embedded",
                               "is" => "here" },
             },
           })
  end

  let(:group) { nil }

  let(:stub_schema) { double("schema", body: [], name: "Schema") }
  let(:stub_subschema) do
    double("subschema",
           name: "Something",
           block_type: object_type,
           fields: [],
           permitted_params: %w[title is],
           id: "something",
           group: group)
  end

  let(:object_type) { "something" }

  before do
    allow(Schema).to receive(:find_by_block_type).with(edition.document.block_type).and_return(stub_schema)
    allow(stub_schema).to receive(:subschema).with(object_type).and_return(stub_subschema)
  end

  describe "#new" do
    describe "when an object type is provided" do
      it "fetches the subschema and renders the template" do
        get new_embedded_object_edition_path(
          edition,
          object_type,
        )

        expect(assigns(:edition)).to eq(edition)
        expect(assigns(:schema)).to eq(stub_schema)
        expect(assigns(:subschema)).to eq(stub_subschema)

        assert_template :new
      end

      it "should enable the unsaved-changes-prompt JS module" do
        get new_embedded_object_edition_path(
          edition,
          object_type,
        )

        doc = Nokogiri::HTML(response.body)
        expect(doc.css("form[data-module~='unsaved-changes-prompt']")).to be_present
      end
    end

    describe "when no object type is provided" do
      describe "when a group is provided" do
        it "renders a list of subschemas for the group" do
          group = "my_group"
          subschemas = [stub_subschema]

          allow(stub_schema).to receive(:subschemas_for_group).with(group).and_return(subschemas)
          allow(stub_schema).to receive(:subschemas).and_return(subschemas)

          get new_embedded_object_edition_path(
            edition,
            group:,
          )

          expect(edition).to eq(assigns(:edition))
          expect(stub_schema).to eq(assigns(:schema))
          expect(group).to eq(assigns(:group))
          expect(subschemas).to eq(assigns(:subschemas))
          expect(assigns(:back_link)).to eq(
            workflow_path(
              edition,
              step: "group_#{group}",
            ),
          )
          expect(assigns(:redirect_path)).to eq(new_embedded_objects_options_redirect_edition_path(edition))
          expect(assigns(:context)).to eq(edition.title)

          assert_template "shared/embedded_objects/select_subschema"
        end

        it "404s if no schemas exist for a given group" do
          group = "my_group"
          subschemas = []
          allow(stub_schema).to receive(:subschemas_for_group).with(group).and_return(subschemas)

          get new_embedded_object_edition_path(
            edition,
            group:,
          )

          expect(response.status).to eq(404)
        end
      end
    end
  end

  describe "#new_embedded_objects_options_redirect" do
    describe "when the object_type param is provided" do
      before do
        post new_embedded_objects_options_redirect_edition_path(
          edition,
          object_type: "something",
          group: "something",
        )
      end

      it "redirects to the path for that object" do
        expect(response).to redirect_to(new_embedded_object_edition_path(edition, object_type: "something"))
      end

      it "sets the back link as a flash" do
        expect(flash[:back_link]).to eq(
          new_embedded_objects_options_redirect_edition_path(
            edition,
            group: "something",
          ),
        )
      end
    end

    describe "when the object_type param is not provided" do
      it "redirects back to the schema select page with an error" do
        post new_embedded_objects_options_redirect_edition_path(
          edition,
          object_type: nil,
          group: "contact_methods",
        )

        expect(response).to redirect_to(
          new_embedded_object_edition_path(
            edition,
            group: "contact_methods",
          ),
        )
        expect(flash[:error]).to eq(I18n.t("activerecord.errors.models.document.attributes.block_type.contact_methods.blank"))
      end
    end
  end

  describe "#create" do
    let(:details) do
      {
        object_type => {
          "title" => "New Thing",
          "is" => "something",
        },
      }
    end

    let(:expected_details) do
      {
        "something" => {
          "embedded" => {
            "title" => "Embedded", "is" => "here"
          },
          "new-thing" => {
            "title" => "New Thing", "is" => "something"
          },
        },
      }
    end

    let(:params) do
      {
        "edition" => { details: },
      }
    end

    it "should create an embedded object for an edition" do
      post create_embedded_object_edition_path(edition, object_type:), params: params

      expect(response).to redirect_to(
        workflow_path(edition, step: "#{Workflow::Step::SUBSCHEMA_PREFIX}#{object_type}"),
      )

      updated_edition = edition.reload

      expect(updated_edition.details).to eq(expected_details)
      expect(flash.[](:success)).to eq("Something added. You can add another something or finish creating the schema block.")
    end

    describe "when the subschema belongs to a group" do
      let(:group) { "some_group" }

      it "should redirect to the group step" do
        post create_embedded_object_edition_path(edition, object_type:), params: params

        expect(response).to redirect_to(
          workflow_path(edition, step: "#{Workflow::Step::GROUP_PREFIX}#{group}"),
        )
        expect(flash.[](:success)).to eq("Something added. You can add another some group or finish creating the schema block.")
      end
    end

    context "when add_another is set" do
      before do
        allow(edition).to receive(:save!)
        post create_embedded_object_edition_path(edition, object_type:), params: params.merge(add_another: "something")
      end

      it "assigns the work-in-progress values to the @edition variable and re-renders the form" do
        expect(response).to(render_template(:new))

        updated_edition = assigns(:edition)

        expect(updated_edition.details).to eq(expected_details)
      end

      it "does not save the edition" do
        expect(edition).not_to have_received(:save!)
      end
    end
  end

  describe "#edit" do
    it "should fetch an object of a particular type" do
      get edit_embedded_object_edition_path(
        edition,
        object_type:,
        object_title: "embedded",
      )

      expect(assigns(:edition)).to eq(edition)
      expect(assigns(:schema)).to eq(stub_schema)
      expect(assigns(:subschema)).to eq(stub_subschema)
      expect(assigns(:object_title)).to eq("embedded")
      expect(assigns(:object)).to eq({ "is" => "here", "title" => "Embedded" })
    end

    it "should assign the redirect_url if given" do
      get edit_embedded_object_edition_path(
        edition,
        object_type:,
        object_title: "embedded",
        redirect_url: "https://example.com",
      )

      expect(assigns(:redirect_url)).to eq("https://example.com")
    end

    it "should 404 if the subschema does not exist" do
      allow(stub_schema).to receive(:subschema).with("something_else").and_return(nil)

      get edit_embedded_object_edition_path(
        edition,
        object_type: "something_else",
        object_title: "embedded",
      )

      expect(response.status).to eq(404)
    end

    it "should 404 if the object cannot be found" do
      allow(stub_schema).to receive(:subschema).with("something_else").and_return(nil)

      get edit_embedded_object_edition_path(
        edition,
        object_type:,
        object_title: "something_else",
      )

      expect(response.status).to eq(404)
    end

    it "should enable the unsaved-changes-prompt JS module" do
      get edit_embedded_object_edition_path(
        edition,
        object_type:,
        object_title: "embedded",
      )

      doc = Nokogiri::HTML(response.body)
      expect(doc.css("form[data-module~='unsaved-changes-prompt']")).to be_present
    end
  end

  describe "#update" do
    let(:details) do
      {
        object_type => {
          "title" => "Embedded",
          "is" => "different",
        },
      }
    end

    let(:object_title) { "embedded" }

    let(:params) do
      {
        redirect_url: documents_path,
        "edition" => {
          details:,
        },
      }
    end

    it "should redirect to the redirect_url" do
      put embedded_object_edition_path(edition, object_type:, object_title:), params: params

      expect(response).to redirect_to(documents_path)
      expect(flash.[](:success)).to eq("Something edited. You can add another something or finish creating the schema block.")
    end

    describe "when the subschema belongs to a group" do
      let(:group) { "some_group" }

      it "should redirect to the redirect_url" do
        put embedded_object_edition_path(edition, object_type:, object_title:), params: params

        expect(response).to redirect_to(documents_path)
        expect(flash.[](:success)).to eq("Something edited. You can add another some group or finish creating the schema block.")
      end
    end

    context "if a new title is given" do
      let(:details) do
        {
          object_type => {
            "title" => "New Name",
            "is" => "different",
          },
        }
      end

      it "should not rename the object" do
        put embedded_object_edition_path(edition, object_type:, object_title:), params: params

        expect(response).to redirect_to(documents_path)

        updated_edition = edition.reload

        expect(updated_edition.details).to eq({ "something" => { "embedded" => details[object_type] } })
      end
    end

    context "if a validation error is thrown" do
      before do
        allow_any_instance_of(Edition).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
      end

      it "should render errors" do
        put embedded_object_edition_path(edition, object_type:, object_title:), params: params

        expect(assigns(:edition)).to eq(edition)
        expect(assigns(:schema)).to eq(stub_schema)
        expect(assigns(:subschema)).to eq(stub_subschema)
        expect(assigns(:object_title)).to eq("embedded")
        expect(assigns(:object).to_h).to eq(details[object_type])

        expect(response).to render_template(:edit)
      end
    end

    context "when add_another is set" do
      before do
        allow(edition).to receive(:save!)
        put embedded_object_edition_path(edition, object_type:, object_title:), params: params.merge(add_another: "something")
      end

      it "assigns the work-in-progress values to the @edition variable and re-renders the form" do
        expect(response).to(render_template(:edit))

        updated_edition = assigns(:edition)

        expect(updated_edition.details).to eq({ "something" => { "embedded" => details[object_type] } })
      end

      it "does not save the edition" do
        expect(edition).not_to have_received(:save!)
      end
    end
  end

  context "when a 1:N subschema has datetime fields requiring validation (e.g. Pension has many date_ranges)" do
    let(:edition) do
      create(:edition,
             :pension,
             details: {})
    end

    let(:parent_schema) { double(:schema, id: "content_block_pension", block_type: "pension") }
    let(:object_type) { "date_range" }

    let(:body) do
      {
        "type" => "object",
        "patternProperties" => {
          "^[a-z0-9-]+$" => {
            "type" => "object",
            "required" => %w[start end],
            "properties" => {
              "title" => {
                "type" => "string",
              },
              "start" => {
                "type" => "string",
                "format" => "date-time",
              },
              "end" => {
                "type" => "string",
                "format" => "date-time",
                "formatMinimum" => { "$ref" => "#/date_range/start" },
              },
            },
          },
        },
      }
    end

    let(:date_ranges_schema) { double("schema", body: [], name: "Pension") }

    let(:date_range_subschema) do
      Schema::EmbeddedSchema.new(object_type, body, parent_schema)
    end

    before do
      allow(Schema).to receive(:find_by_block_type).with(edition.document.block_type).and_return(date_ranges_schema)
      allow(date_ranges_schema).to receive(:subschema).with("date_range").and_return(date_range_subschema)
    end

    describe "#create" do
      let(:valid_params) do
        {
          "edition" =>
            { "details" => {
              "date_range" => {
                "title" => "Tax Year 2025-26",
                "start(1i)" => "2025",
                "start(2i)" => "04",
                "start(3i)" => "06",
                "start(4i)" => "00",
                "start(5i)" => "00",
                "end(1i)" => "2026",
                "end(2i)" => "04",
                "end(3i)" => "05",
                "end(4i)" => "23",
                "end(5i)" => "59",
              },
            } },
        }
      end

      it "converts datetime params to ISO 8601 and saves" do
        post create_embedded_object_edition_path(edition, object_type: :date_range),
             params: valid_params

        updated_edition = edition.reload
        date_range = updated_edition.details["date_range"]["tax-year-2025-26"]

        expect(date_range["start"]).to eq("2025-04-06T00:00:00+01:00")
        expect(date_range["end"]).to eq("2026-04-05T23:59:00+01:00")
      end

      context "when the start date is invalid (30 Feb)" do
        let(:invalid_params) do
          {
            "edition" =>
              { "details" => {
                "date_range" => {
                  "title" => "Invalid Range",
                  "start(1i)" => "2025",
                  "start(2i)" => "02",
                  "start(3i)" => "30",
                  "start(4i)" => "00",
                  "start(5i)" => "00",
                  "end(1i)" => "2026",
                  "end(2i)" => "04",
                  "end(3i)" => "05",
                  "end(4i)" => "23",
                  "end(5i)" => "59",
                },
              } },
          }
        end

        it "re-renders the form with validation errors" do
          post create_embedded_object_edition_path(edition, object_type: :date_range),
               params: invalid_params

          expect(response).to render_template(:new)
          expect(response).to have_http_status(:unprocessable_content)
        end

        it "preserves the raw submitted values in @object for form repopulation" do
          post create_embedded_object_edition_path(edition, object_type: :date_range),
               params: invalid_params

          object = assigns(:object)

          expect(object["start(3i)"]).to eq("30")
          expect(object["start(2i)"]).to eq("02")
          expect(object["start(1i)"]).to eq("2025")
        end
      end

      context "when the end datetime is before the start datetime" do
        let(:invalid_params) do
          {
            "edition" =>
              { "details" => {
                "date_range" => {
                  "title" => "Backwards Range",
                  "start(1i)" => "2026",
                  "start(2i)" => "04",
                  "start(3i)" => "06",
                  "start(4i)" => "00",
                  "start(5i)" => "00",
                  "end(1i)" => "2025",
                  "end(2i)" => "04",
                  "end(3i)" => "05",
                  "end(4i)" => "23",
                  "end(5i)" => "59",
                },
              } },
          }
        end

        it "re-renders the form with validation errors" do
          post create_embedded_object_edition_path(edition, object_type: :date_range),
               params: invalid_params

          expect(response).to render_template(:new)
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    describe "#update" do
      let(:object_title) { "existing-range" }

      before do
        edition.details["date_range"] = {
          object_title => {
            "title" => "Existing Range",
            "start" => "2024-04-06T00:00:00+01:00",
            "end" => "2025-04-05T23:59:00+01:00",
          },
        }
        edition.save!
      end

      let(:valid_params) do
        {
          redirect_url: documents_path,
          "edition" =>
            { "details" => {
              "date_range" => {
                "title" => "Existing Range",
                "start(1i)" => "2025",
                "start(2i)" => "04",
                "start(3i)" => "06",
                "start(4i)" => "00",
                "start(5i)" => "00",
                "end(1i)" => "2026",
                "end(2i)" => "04",
                "end(3i)" => "05",
                "end(4i)" => "23",
                "end(5i)" => "59",
              },
            } },
        }
      end

      it "converts datetime params to ISO 8601 and saves" do
        put embedded_object_edition_path(edition, object_type: :date_range, object_title:),
            params: valid_params

        updated_edition = edition.reload
        date_range = updated_edition.details["date_range"][object_title]

        expect(date_range["start"]).to eq("2025-04-06T00:00:00+01:00")
        expect(date_range["end"]).to eq("2026-04-05T23:59:00+01:00")
      end

      context "when the start date is invalid (30 Feb)" do
        let(:invalid_params) do
          {
            redirect_url: documents_path,
            "edition" =>
              { "details" => {
                "date_range" => {
                  "title" => "Existing Range",
                  "start(1i)" => "2025",
                  "start(2i)" => "02",
                  "start(3i)" => "30",
                  "start(4i)" => "00",
                  "start(5i)" => "00",
                  "end(1i)" => "2026",
                  "end(2i)" => "04",
                  "end(3i)" => "05",
                  "end(4i)" => "23",
                  "end(5i)" => "59",
                },
              } },
          }
        end

        it "re-renders the form with validation errors" do
          put embedded_object_edition_path(edition, object_type: :date_range, object_title:),
              params: invalid_params

          expect(response).to render_template(:edit)
          expect(response).to have_http_status(:unprocessable_content)
        end

        it "preserves the raw submitted values in @object for form repopulation" do
          put embedded_object_edition_path(edition, object_type: :date_range, object_title:),
              params: invalid_params

          object = assigns(:object)

          expect(object["start(3i)"]).to eq("30")
          expect(object["start(2i)"]).to eq("02")
          expect(object["start(1i)"]).to eq("2025")
        end
      end
    end
  end
end
