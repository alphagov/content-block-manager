require "capybara/rails"

RSpec.describe EmbeddedObjects, type: :request do
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

        expect(edition).to eq(assigns(:edition))
        expect(stub_schema).to eq(assigns(:schema))
        expect(stub_subschema).to eq(assigns(:subschema))

        assert_template :new
      end
    end

    describe "when no object type is provided" do
      describe "when a group is provided" do
        it "renders a list of subschemas for the group" do
          group = "my_group"
          subschemas = [stub_subschema]

          allow(stub_schema).to receive(:subschemas_for_group).with(group).and_return(subschemas)

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
          expect(new_embedded_objects_options_redirect_edition_path(edition)).to eq(assigns(:redirect_path))
          expect(edition.title).to eq(assigns(:context))

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

          expect(404).to eq(response.status)
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
    it "should create an embedded object for an edition" do
      post create_embedded_object_edition_path(
        edition,
        object_type:,
      ), params: {
        "edition" => {
          details: {
            object_type => {
              "title" => "New Thing",
              "is" => "something",
            },
          },
        },
      }

      expect(response).to redirect_to(
        workflow_path(edition, step: "#{Workflow::Step::SUBSCHEMA_PREFIX}#{object_type}"),
      )

      updated_edition = edition.reload

      expect(updated_edition.details).to eq(
        {
          "something" => {
            "embedded" => {
              "title" => "Embedded", "is" => "here"
            },
            "new-thing" => {
              "title" => "New Thing", "is" => "something"
            },
          },
        },
      )
      expect(flash.[](:notice)).to eq("Something added. You can add another something or finish creating the schema block.")
    end

    describe "when the subschema belongs to a group" do
      let(:group) { "some_group" }

      it "should redirect to the group step" do
        post create_embedded_object_edition_path(
          edition,
          object_type:,
        ), params: {
          "edition" => {
            details: {
              object_type => {
                "title" => "New Thing",
                "is" => "something",
              },
            },
          },
        }

        expect(response).to redirect_to(
          workflow_path(edition, step: "#{Workflow::Step::GROUP_PREFIX}#{group}"),
        )
        expect(flash.[](:notice)).to eq("Something added. You can add another some group or finish creating the schema block.")
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

      expect(edition).to eq(assigns(:edition))
      expect(stub_schema).to eq(assigns(:schema))
      expect(stub_subschema).to eq(assigns(:subschema))
      expect("embedded").to eq(assigns(:object_title))
      expect({ "is" => "here", "title" => "Embedded" }).to eq(assigns(:object))
    end

    it "should assign the redirect_url if given" do
      get edit_embedded_object_edition_path(
        edition,
        object_type:,
        object_title: "embedded",
        redirect_url: "https://example.com",
      )

      expect("https://example.com").to eq(assigns(:redirect_url))
    end

    it "should 404 if the subschema does not exist" do
      allow(stub_schema).to receive(:subschema).with("something_else").and_return(nil)

      get edit_embedded_object_edition_path(
        edition,
        object_type: "something_else",
        object_title: "embedded",
      )

      expect(404).to eq(response.status)
    end

    it "should 404 if the object cannot be found" do
      allow(stub_schema).to receive(:subschema).with("something_else").and_return(nil)

      get edit_embedded_object_edition_path(
        edition,
        object_type:,
        object_title: "something_else",
      )

      expect(404).to eq(response.status)
    end
  end

  describe "#update" do
    it "should redirect to the redirect_url" do
      put embedded_object_edition_path(
        edition,
        object_type:,
        object_title: "embedded",
      ), params: {
        redirect_url: documents_path,
        "edition" => {
          details: {
            object_type => {
              "title" => "Embedded",
              "is" => "different",
            },
          },
        },
      }

      expect(response).to redirect_to(documents_path)
      expect(flash.[](:notice)).to eq("Something edited. You can add another something or finish creating the schema block.")
    end

    describe "when the subschema belongs to a group" do
      let(:group) { "some_group" }

      it "should redirect to the redirect_url" do
        put embedded_object_edition_path(
          edition,
          object_type:,
          object_title: "embedded",
        ), params: {
          redirect_url: documents_path,
          "edition" => {
            details: {
              object_type => {
                "title" => "Embedded",
                "is" => "different",
              },
            },
          },
        }

        expect(response).to redirect_to(documents_path)
        expect(flash.[](:notice)).to eq("Something edited. You can add another some group or finish creating the schema block.")
      end
    end

    it "should not rename the object if a new title is given" do
      put embedded_object_edition_path(
        edition,
        object_type:,
        object_title: "embedded",
      ), params: {
        redirect_url: documents_path,
        "edition" => {
          details: {
            object_type => {
              "title" => "New Name",
              "is" => "different",
            },
          },
        },
      }

      expect(response).to redirect_to(documents_path)

      updated_edition = edition.reload

      expect({ "something" => { "embedded" => { "title" => "New Name", "is" => "different" } } }).to eq(updated_edition.details)
    end

    it "should render errors if a validation error is thrown" do
      allow_any_instance_of(Edition).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)

      put embedded_object_edition_path(
        edition,
        object_type:,
        object_title: "embedded",
      ), params: {
        "edition" => {
          details: {
            object_type => {
              "title" => "New Name",
              "is" => "different",
            },
          },
        },
      }

      expect(edition).to eq(assigns(:edition))
      expect(stub_schema).to eq(assigns(:schema))
      expect(stub_subschema).to eq(assigns(:subschema))
      expect("embedded").to eq(assigns(:object_title))
      expect(assigns(:object).to_h).to eq(
        {
          "title" => "New Name",
          "is" => "different",
        },
      )

      expect(response).to render_template(:edit)
    end
  end
end
