RSpec.describe "Workflow", type: :request do
  include Rails.application.routes.url_helpers

  def self.it_shows_the_correct_context
    it "shows the correct context" do
      get workflow_path(id: edition.id, step:)

      expect(page).to have_selector(".govuk-caption-xl", text: edition.title)
    end
  end

  def self.it_has_the_correct_ga4_attributes(attributes)
    it "has the correct GA4 attributes" do
      get workflow_path(id: edition.id, step:)

      expect(page).to have_selector("form[data-module='ga4-form-tracker']")
      expect(page).to have_selector("form[data-ga4-form='#{attributes.to_json}']")
    end
  end

  let(:details) do
    {
      foo: "Foo text",
      bar: "Bar text",
    }
  end

  let(:organisation) { build(:organisation) }
  let(:document) { create(:document, :pension, content_id: @content_id, sluggable_string: "some-slug") }
  let(:edition) { create(:edition, document:, details:, lead_organisation_id: organisation.id, instructions_to_publishers: "instructions", title: "Some Edition Title") }

  let!(:schema) { stub_request_for_schema("pension") }

  before do
    login_as_admin
    @content_id = "49453854-d8fd-41da-ad4c-f99dbac601c3"

    stub_publishing_api_has_embedded_content(content_id: @content_id, total: 0, results: [], order: HostContentItem::DEFAULT_ORDER)
    allow(Organisation).to receive(:all).and_return([organisation])
  end

  describe "when creating a new content block" do
    before do
      allow_any_instance_of(Document).to receive(:is_new_block?).and_return(true)
    end

    describe "when on the edit step" do
      let(:step) { :edit_draft }

      describe "#show" do
        it_shows_the_correct_context

        it_has_the_correct_ga4_attributes({ type: "Content Block", tool_name: "pension", event_name: "create", section: "edit" })
      end
    end

    describe "when reviewing the changes" do
      let(:step) { :review }

      describe "#show" do
        it_shows_the_correct_context
        it_has_the_correct_ga4_attributes({ type: "Content Block", tool_name: "pension", event_name: "create", section: "review" })

        it "shows the new edition for review" do
          get workflow_path(id: edition.id, step:)

          expect(response).to render_template("editions/workflow/review")
          expect(assigns(:edition)).to eq(edition)
        end

        it "shows the correct context and confirmation text" do
          get workflow_path(id: edition.id, step:)

          expect(page).to have_content(document.title)
          expect(page).to have_content("I confirm that the details I’ve put into the content block have been checked and are factually correct.")
        end
      end

      describe "#update" do
        it "posts the new edition to the Publishing API and marks edition as published" do
          assert_edition_is_published do
            put workflow_path(id: edition.id, step:, is_confirmed: true, save_action: "publish")
          end
        end
      end
    end

    describe "when the edition details have not been confirmed" do
      let(:step) { :review }

      describe "#update" do
        it "returns to the review page" do
          put workflow_path(id: edition.id, step:)

          expect(response).to render_template("editions/workflow/review")
        end
      end
    end

    describe "when subschemas are present" do
      let(:subschemas) do
        [
          double("subschema_1", id: "subschema_1", name: "subschema_1", block_type: "subschema_1", block_display_fields: [], fields: [double("field", name: "name", data_attributes: nil)], group: nil),
          double("subschema_2", id: "subschema_2", name: "subschema_2", block_type: "subschema_1", fields: [], group: nil),
        ]
      end

      let!(:schema) { stub_request_for_schema("pension", subschemas:) }

      describe "#show" do
        let(:step) { "embedded_subschema_1" }

        it_has_the_correct_ga4_attributes({ type: "Content Block", tool_name: "pension", event_name: "create", section: "embedded_subschema_1" })
        it_shows_the_correct_context

        it "shows the form for the first subschema" do
          get workflow_path(id: edition.id, step: "embedded_subschema_1")

          expect(response).to render_template("editions/workflow/embedded_objects")
        end

        it "shows the form for the second subschema" do
          get workflow_path(id: edition.id, step: "embedded_subschema_2")

          expect(response).to render_template("editions/workflow/embedded_objects")
        end

        describe "when there are existing subschema blocks created already" do
          let(:details) { { subschema_1: { existing_subschema: { name: "existing subschema" } } } }
          let(:edition) { create(:edition, document:, details:, lead_organisation_id: organisation.id, instructions_to_publishers: "instructions", title: "Some Edition Title") }

          it "shows the existing block and how to add another embedded block" do
            get workflow_path(id: edition.id, step: "embedded_subschema_1")

            expect(page).to have_content("existing subschema")
            expect(page).to have_content("Add another subschema 1")
          end
        end
      end

      describe "#update" do
        it "redirects to the second subschema" do
          put workflow_path(id: edition.id, step: "embedded_subschema_1")

          expect(response).to redirect_to(workflow_path(id: edition.id, step: :embedded_subschema_2))
        end

        it "redirects to the review page" do
          put workflow_path(id: edition.id, step: "embedded_subschema_2")

          expect(response).to redirect_to(workflow_path(id: edition.id, step: :review))
        end
      end
    end
  end

  describe "when updating an existing content block" do
    before do
      allow_any_instance_of(Document).to receive(:is_new_block?).and_return(false)
    end

    describe "when editing an existing edition" do
      let(:step) { :edit_draft }

      describe "#show" do
        it_shows_the_correct_context
        it_has_the_correct_ga4_attributes({ type: "Content Block", tool_name: "pension", event_name: "update", section: "edit" })

        it "shows the form" do
          get workflow_path(id: edition.id, step:)

          expect(response).to render_template("editions/workflow/edit_draft")
        end
      end

      describe "#update" do
        it "updates the block and redirects to the next flow if editing an existing block" do
          allow_any_instance_of(Document).to receive(:is_new_block?).and_return(false)

          put workflow_path(id: edition.id, step:),
              params: {
                "edition" => {
                  "title" => "New title",
                  "lead_organisation_id" => organisation.id,
                  "details" => {
                    "foo" => "bar",
                  },
                },
              }

          expect(response).to redirect_to(workflow_path(id: edition.id, step: :review_links))

          expect(edition.reload.title).to eq("New title")
          expect(edition.reload.details["foo"]).to eq("bar")
          expect(edition.reload.details["bar"]).to eq("Bar text")
        end

        it "updates the block with nil if a details field is blank" do
          put workflow_path(id: edition.id, step:),
              params: {
                "edition" => {
                  "title" => "New title",
                  "lead_organisation_id" => organisation.id,
                  "details" => {
                    "foo" => "",
                  },
                },
              }

          expect(edition.reload.details["foo"]).to be_nil
        end

        it "updates the block and redirects to the review page if editing a new block" do
          allow_any_instance_of(Document).to receive(:is_new_block?).and_return(true)

          put workflow_path(id: edition.id, step:),
              params: {
                "edition" => {
                  "title" => "New title",
                  "lead_organisation_id" => organisation.id,
                  "details" => {
                    "foo" => "bar",
                  },
                },
              }

          expect(response).to redirect_to(workflow_path(id: edition.id, step: :review))

          expect(edition.reload.title).to eq("New title")
          expect(edition.reload.details["foo"]).to eq("bar")
          expect(edition.reload.details["bar"]).to eq("Bar text")
        end

        it "shows an error if a required field is blank" do
          put workflow_path(id: edition.id, step:),
              params: {
                "edition" => {
                  "title" => "",
                  "details" => {
                    "foo" => "bar",
                  },
                },
              }

          expect(response).to render_template("editions/workflow/edit_draft")
          expect(page).to have_text(I18n.t("activerecord.errors.models.edition.blank", attribute: "Title"))
        end
      end
    end

    describe "when reviewing the links" do
      let(:step) { :review_links }

      describe "#show" do
        describe "when there is embedded content" do
          let(:host_content_items) do
            10.times.map do |i|
              {
                "title" => "Content #{i}",
                "document_type" => "document",
                "base_path" => "/",
                "content_id" => SecureRandom.uuid,
                "last_edited_by_editor_id" => SecureRandom.uuid,
                "last_edited_at" => 2.days.ago.to_s,
                "host_content_id" => "abc12345",
                "primary_publishing_organisation" => {
                  "content_id" => SecureRandom.uuid,
                  "title" => "Organisation #{i}",
                  "base_path" => "/organisation/#{i}",
                },
              }
            end
          end
          let(:host_content_item_users) { build_list(:signon_user, 10) }

          before do
            stub_publishing_api_has_embedded_content_for_any_content_id(
              results: host_content_items,
              total: host_content_items.length,
              order: HostContentItem::DEFAULT_ORDER,
            )
            allow(SignonUser).to receive(:with_uuids).with(host_content_items.map { |i| i["last_edited_by_editor_id"] }).and_return(host_content_item_users)
          end

          it_shows_the_correct_context
          it_has_the_correct_ga4_attributes({ type: "Content Block", tool_name: "pension", event_name: "update", section: "review_links" })
        end

        describe "when there is no embedded content" do
          before do
            stub_publishing_api_has_embedded_content_for_any_content_id(
              results: [],
              total: 0,
              order: HostContentItem::DEFAULT_ORDER,
            )
          end

          it "redirects to the next step" do
            get workflow_path(id: edition.id, step:)

            expect(response).to redirect_to(workflow_path(id: edition.id, step: :internal_note))
          end

          describe "when the request comes from the next step" do
            it "redirects to the previous step" do
              get workflow_path(id: edition.id, step:),
                  headers: { "HTTP_REFERER" => "http://example.com#{workflow_path(id: edition.id, step: :internal_note)}" }

              expect(response).to redirect_to(workflow_path(id: edition.id, step: :edit_draft))
            end
          end
        end
      end

      describe "#update" do
        it "redirects to the next step" do
          put workflow_path(id: edition.id, step:)

          expect(request).to redirect_to(workflow_path(id: edition.id, step: :internal_note))
        end
      end
    end

    describe "when updating the internal note" do
      let(:step) { :internal_note }

      describe "#show" do
        it_shows_the_correct_context
        it_has_the_correct_ga4_attributes({ type: "Content Block", tool_name: "pension", event_name: "update", section: "internal_note" })

        it "shows the form" do
          get workflow_path(id: edition.id, step:)

          expect(response).to render_template("editions/workflow/internal_note")
        end
      end

      describe "#update" do
        it "adds the note and redirects" do
          change_note = "This is my note"
          put workflow_path(id: edition.id, step:),
              params: {
                "edition" => {
                  "internal_change_note" => change_note,
                },
              }

          expect(response).to redirect_to(workflow_path(id: edition.id, step: :change_note))
          expect(edition.reload.internal_change_note).to eq(change_note)
        end
      end
    end

    describe "when updating the change note" do
      let(:step) { :change_note }

      describe "#show" do
        it_shows_the_correct_context
        it_has_the_correct_ga4_attributes({ type: "Content Block", tool_name: "pension", event_name: "update", section: "change_note" })

        it "shows the form" do
          get workflow_path(id: edition.id, step:)

          expect(response).to render_template("editions/workflow/change_note")
        end
      end

      describe "#update" do
        it "adds the note and redirects" do
          change_note = "This is my note"
          put workflow_path(id: edition.id, step:),
              params: {
                "edition" => {
                  "major_change" => "1",
                  "change_note" => change_note,
                },
              }

          expect(edition.reload.change_note).to eq(change_note)
          expect(edition.reload.major_change).to be_truthy

          expect(response).to redirect_to(workflow_path(id: edition.id, step: :schedule_publishing))
        end

        it "shows an error if the change is major and the change note is blank" do
          put workflow_path(id: edition.id, step:),
              params: {
                "edition" => {
                  "major_change" => "1",
                  "change_note" => "",
                },
              }

          expect(page).to have_text(I18n.t("activerecord.errors.models.edition.blank", attribute: "Change note"))
        end

        it "shows an error if major_change is blank" do
          put workflow_path(id: edition.id, step:),
              params: {
                "edition" => {
                  "major_change" => "",
                  "change_note" => "",
                },
              }

          expect(page).to have_text(I18n.t("activerecord.errors.models.edition.attributes.major_change.inclusion"))
        end
      end

      describe "when subschemas are present" do
        let(:subschemas) do
          [
            double("subschema", id: "subschema_1", name: "subschema_1", block_type: "subschema_1", group: nil),
            double("subschema", id: "subschema_2", name: "subschema_2", block_type: "subschema_2", group: nil),
          ]
        end

        let!(:schema) { stub_request_for_schema("pension", subschemas:) }

        before do
          allow_any_instance_of(Edition).to receive(:has_entries_for_subschema_id?).and_return(true)
        end

        describe "#show" do
          let(:step) { "embedded_subschema_1" }

          it_has_the_correct_ga4_attributes({ type: "Content Block", tool_name: "pension", event_name: "update", section: "embedded_subschema_1" })

          it "shows the form for the first subschema" do
            get workflow_path(id: edition.id, step: "embedded_subschema_1")

            expect(response).to render_template("editions/workflow/embedded_objects")
          end

          it "shows the form for the second subschema" do
            get workflow_path(id: edition.id, step: "embedded_subschema_2")

            expect(response).to render_template("editions/workflow/embedded_objects")
          end
        end

        describe "#update" do
          it "redirects to the second subschema" do
            put workflow_path(id: edition.id, step: "embedded_subschema_1")

            expect(response).to redirect_to(workflow_path(id: edition.id, step: :embedded_subschema_2))
          end

          it "redirects to review links" do
            put workflow_path(id: edition.id, step: "embedded_subschema_2")

            expect(response).to redirect_to(workflow_path(id: edition.id, step: :review_links))
          end
        end
      end

      describe "when subschemas are present" do
        let(:group) { nil }
        let(:subschemas) do
          [
            double("subschema", id: "subschema_1", name: "subschema_1", block_type: "subschema_1", group:, group_order: 0, fields: []),
            double("subschema", id: "subschema_2", name: "subschema_2", block_type: "subschema_2", group:, group_order: 1, fields: []),
          ]
        end

        let!(:schema) { stub_request_for_schema("pension", subschemas:) }

        before do
          allow_any_instance_of(Edition).to receive(:has_entries_for_subschema_id?).and_return(true)
        end

        describe "#show" do
          let(:step) { "embedded_subschema_1" }
          it_has_the_correct_ga4_attributes({ type: "Content Block", tool_name: "pension", event_name: "update", section: "embedded_subschema_1" })

          it "shows the form for the first subschema" do
            get workflow_path(id: edition.id, step: "embedded_subschema_1")

            expect(response).to render_template("editions/workflow/embedded_objects")
          end

          it "shows the form for the second subschema" do
            get workflow_path(id: edition.id, step: "embedded_subschema_2")

            expect(response).to render_template("editions/workflow/embedded_objects")
          end
        end

        describe "#update" do
          it "redirects to the second subschema" do
            put workflow_path(id: edition.id, step: "embedded_subschema_1")

            expect(response).to redirect_to(workflow_path(id: edition.id, step: :embedded_subschema_2))
          end

          it "redirects to review links" do
            put workflow_path(id: edition.id, step: "embedded_subschema_2")

            expect(response).to redirect_to(workflow_path(id: edition.id, step: :review_links))
          end
        end

        describe "when the subschemas are in a group" do
          let(:group) { "some_group" }

          before do
            allow(schema).to receive(:subschemas_for_group).with(group).and_return(subschemas)
          end

          describe "#show" do
            describe "when content exists for at least some of the subschemas" do
              let(:details) do
                {
                  subschemas[0].block_type.to_s => {
                    "item" => {
                      "key" => "value",
                    },
                  },
                }
              end

              it "shows the form for the group" do
                get workflow_path(id: edition.id, step: "group_some_group")

                expect(response).to render_template("editions/workflow/group_objects")
              end
            end

            describe "when content does not exist for any of the subschemas" do
              it "renders the select subschema group" do
                get workflow_path(id: edition.id, step: "group_some_group")

                expect(response).to render_template("shared/embedded_objects/select_subschema")
              end
            end
          end

          describe "#update" do
            it "redirects to review links" do
              put workflow_path(id: edition.id, step: "group_some_group")

              expect(response).to redirect_to(workflow_path(id: edition.id, step: :review_links))
            end
          end
        end
      end
    end

    describe "when scheduling or publishing" do
      let(:step) { :schedule_publishing }

      describe "#show" do
        it_shows_the_correct_context
        it_has_the_correct_ga4_attributes({ type: "Content Block", tool_name: "pension", event_name: "update", section: "schedule_publishing" })

        it "shows the form" do
          get workflow_path(id: edition.id, step:)

          expect(response).to render_template("editions/workflow/schedule_publishing")
          expect(assigns(:document)).to eq(document)
        end
      end

      describe "#update" do
        describe "when choosing to publish immediately" do
          it "redirects to the review step" do
            scheduled_at = {
              "scheduled_publication(1i)": "",
              "scheduled_publication(2i)": "",
              "scheduled_publication(3i)": "",
              "scheduled_publication(4i)": "",
              "scheduled_publication(5i)": "",
            }

            put workflow_path(id: edition.id, step:),
                params: {
                  schedule_publishing: "now",
                  scheduled_at:,
                }

            expect(response).to redirect_to(workflow_path(id: edition.id, step: :review))
          end
        end

        describe "when scheduling publication" do
          it "redirects to the internal note page" do
            date = Time.zone.now + 1.day

            scheduled_at = {
              "scheduled_publication(1i)": date.year.to_s,
              "scheduled_publication(2i)": date.month.to_s,
              "scheduled_publication(3i)": date.day.to_s,
              "scheduled_publication(4i)": date.hour.to_s,
              "scheduled_publication(5i)": date.min.to_s,
            }

            put workflow_path(id: edition.id, step:), params: {
              schedule_publishing: "schedule",
              scheduled_at:,
            }

            expect(response).to redirect_to(workflow_path(id: edition.id, step: :review))
          end
        end

        describe "when leaving the schedule_publishing param blank" do
          it "shows an error message" do
            put workflow_path(id: edition.id, step:)

            expect(response).to render_template("editions/workflow/schedule_publishing")
            expect(page).to have_text(I18n.t("activerecord.errors.models.edition.attributes.schedule_publishing.blank"))
          end
        end
      end
    end

    describe "when on the review step" do
      let(:step) { :review }
      it_shows_the_correct_context
      it_has_the_correct_ga4_attributes({ type: "Content Block", tool_name: "pension", event_name: "update", section: "review" })

      it "shows the correct context and confirmation text" do
        get workflow_path(id: edition.id, step:)

        expect(page).to have_text(document.title)
        expect(page).to have_text("I confirm that the details I’ve put into the content block have been checked and are factually correct.")
      end
    end
  end

  describe "when an unknown step is provided" do
    describe "#show" do
      it "returns a 404" do
        get workflow_path(id: edition.id, step: "some_random_step")

        expect(response.code).to eq("404")
      end
    end

    describe "#update" do
      it "returns a 404" do
        put workflow_path(id: edition.id, step: "some_random_step")

        expect(response.code).to eq("404")
      end
    end
  end

  describe "when an unknown subschema step is provided" do
    describe "#show" do
      it "returns a 404" do
        get workflow_path(id: edition.id, step: "embedded_something")

        expect(response.code).to eq("404")
      end
    end
  end

  describe "when an unknown group step is provided" do
    describe "#show" do
      it "returns a 404" do
        get workflow_path(id: edition.id, step: "group_something")

        expect(response.code).to eq("404")
      end
    end
  end
end

def assert_edition_is_published(&block)
  fake_put_content_response = GdsApi::Response.new(
    double("http_response", code: 200, body: {}),
  )
  fake_publish_content_response = GdsApi::Response.new(
    double("http_response", code: 200, body: {}),
  )

  payload = PublishingApi::ContentBlockPresenter.new(schema_id: "content_block_type", content_id_alias: "some-slug", edition: edition).present

  expect(Services.publishing_api).to receive(:put_content).with(@content_id, payload).and_return(fake_put_content_response)
  expect(Services.publishing_api).to receive(:publish).with(@content_id).and_return(fake_publish_content_response)

  block.call

  document = Document.find_by!(content_id: @content_id)
  new_edition = document.most_recent_edition

  expect(new_edition.state).to eq("published")
end

def update_params(edition_id:, organisation_id:)
  {
    id: edition_id,
    schedule_publishing: "schedule",
    scheduled_at: {
      "scheduled_publication(3i)": "2",
      "scheduled_publication(2i)": "9",
      "scheduled_publication(1i)": "2024",
      "scheduled_publication(4i)": "10",
      "scheduled_publication(5i)": "05",
    },
    "edition": {
      creator: "1",
      details: { foo: "newnew@example.com", bar: "edited" },
      document_attributes: { block_type: "pension", title: "Another email" },
      organisation_id:,
    },
  }
end
