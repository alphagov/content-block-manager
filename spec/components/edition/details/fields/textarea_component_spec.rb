COMPONENT_CLASS = ".app-c-content-block-manager-textarea-component".freeze

RSpec.describe Edition::Details::Fields::TextareaComponent, type: :component do
  let(:described_class) { Edition::Details::Fields::TextareaComponent }
  let(:helper_stub) { double(:helpers) }

  let(:edition) { build(:edition, :contact) }

  before do
    allow_any_instance_of(described_class).to receive(:helpers).and_return(helper_stub)
    allow(helper_stub).to receive(:humanized_label).and_return("Translated label")
    allow(helper_stub).to receive(:hint_text).and_return(nil)
  end

  context "when textarea is built for a schema" do
    let(:properties) do
      {
        "rich_field" => { "type" => "string" },
        "plain_field" => { "type" => "string" },
      }
    end

    let(:body) do
      {
        "type" => "object",
        "properties" => properties,
      }
    end

    let(:schema_id) { "content_block_contact" }

    let(:config) do
      {
        "schemas" => {
          schema_id => {
            "fields" => {
              "rich_field" => {
                "component" => "textarea",
                "govspeak_enabled" => true,
              },
              "plain_field" => {
                "component" => "textarea",
              },
            },
          },
        },
      }
    end

    let(:schema) { Schema.new(schema_id, body) }

    let(:rich_field) do
      Schema::Field.new(
        "rich_field",
        schema,
      )
    end

    let(:plain_field) do
      Schema::Field.new(
        "plain_field",
        schema,
      )
    end

    let(:field_value) { nil }

    let(:component) do
      described_class.new(
        edition: edition,
        field: rich_field,
        schema: schema,
        value: field_value,
      )
    end

    before do
      allow(Schema).to receive(:schema_settings).and_return(config)
    end

    it "gives the textarea an ID describing path to field" do
      render_inline component

      expect(page).to have_css(COMPONENT_CLASS) do |component|
        expected_id = "edition_details_rich_field"

        expect(component).to have_css(
          "textarea[id='#{expected_id}']",
        )
      end
    end

    it "includes a translated _label_" do
      render_inline component

      expect(page).to have_css(COMPONENT_CLASS) do |component|
        displays_label_using_translation_system(component)
      end
    end

    it "includes a _name_ attribute representing nested field location" do
      render_inline component

      expect(page).to have_css(COMPONENT_CLASS) do |component|
        expected_name_attribute =
          "edition[details][rich_field]"

        expect(component).to have_css(
          "textarea[name='#{expected_name_attribute}']",
        )
      end
    end

    describe "error handling" do
      context "when there is an error on the field" do
        before do
          edition.errors.add(
            :details_rich_field,
            "blank",
          )

          expect(I18n).to receive(:t).with(
            "activerecord.errors.models.edition" \
              ".attributes.details_rich_field.format".to_sym,
            hash_including(message: "blank"),
          ).and_return("Rich field must be present")
        end

        it "adds an error class to the form group to highlight the area needing attention" do
          render_inline component

          expect(page).to have_css(COMPONENT_CLASS) do |component|
            expect(component).to have_css(".govuk-form-group.govuk-form-group--error")
          end
        end

        it "adds an error message to clarify the error and remedial action required" do
          render_inline component

          expect(page).to have_css(COMPONENT_CLASS) do |component|
            expect(component).to have_css(
              ".govuk-error-message",
              text: "Rich field must be present",
            )
          end
        end
      end
    end

    describe "'Govspeak supported' indicator" do
      context "when the field IS declared 'govspeak-enabled' in the config" do
        let(:component) do
          described_class.new(
            edition: edition,
            field: rich_field,
            schema: schema,
            value: field_value,
          )
        end

        it "displays guidance to indicate 'Govspeak supported'" do
          render_inline component

          expect(page).to have_css(COMPONENT_CLASS) do |component|
            displays_indication_that_govspeak_is_supported(component)
          end
        end

        describe "hint ID mapping to textarea 'aria-describedby'" do
          let(:expected_hint_id_to_aria_mapping) do
            "edition_details_rich_field-hint"
          end

          it "includes an 'aria-describedby' attribute on the textarea, to match the label hint's ID" do
            render_inline component

            expect(page).to have_css(COMPONENT_CLASS) do |component|
              expect(component).to have_css(
                "textarea[aria-describedby='#{expected_hint_id_to_aria_mapping}']",
              )
            end
          end

          it "includes a 'Preview' button" do
            render_inline component

            expect(page).to have_css(COMPONENT_CLASS) do |component|
              expect(component).to have_css(
                "button.js-app-c-govspeak-editor__preview-button",
                text: "Preview",
              )
            end
          end

          it "includes a 'Back to edit' button" do
            render_inline component

            expect(page).to have_css(COMPONENT_CLASS) do |component|
              expect(component).to have_css(
                "button.js-app-c-govspeak-editor__back-button",
                text: "Back to edit",
              )
            end
          end

          it "includes a preview element to be replaced by the Govspeak which JS will render into HTML" do
            render_inline component

            expect(page).to have_css(COMPONENT_CLASS) do |component|
              expect(component).to have_css(
                ".app-c-govspeak-editor__preview.js-locale-switcher-custom p",
                text: "Generating preview, please wait.",
              )
            end
          end
        end
      end

      context "when the field is NOT declared 'govspeak-enabled in the config" do
        let(:component) do
          described_class.new(
            edition: edition,
            field: plain_field,
            schema: schema,
            value: field_value,
          )
        end

        it "does NOT display the 'Govspeak supported' hint" do
          render_inline component

          expect(page).to have_css(COMPONENT_CLASS) do |component|
            displays_no_indication_that_govspeak_is_supported(component)
          end
        end

        it "does NOT  include a 'Preview' button" do
          render_inline component

          expect(page).to have_css(COMPONENT_CLASS) do |component|
            component.assert_no_selector(
              "button.js-app-c-govspeak-editor__preview-button",
              text: "Preview",
            )
          end
        end

        it "does NOT include 'Back to edit' button" do
          render_inline component

          expect(page).to have_css(COMPONENT_CLASS) do |component|
            component.assert_no_selector(
              "button.js-app-c-govspeak-editor__back-button",
              text: "Back to edit",
            )
          end
        end

        it "does NOT include a preview element to be replaced by the rendered Govspeak" do
          render_inline component

          expect(page).to have_css(COMPONENT_CLASS) do |component|
            component.assert_no_selector(
              ".app-c-govspeak-editor__preview.js-locale-switcher-custom p",
              text: "Generating preview, please wait.",
            )
          end
        end
      end
    end
  end

  context "when textarea is built for a subschema" do
    let(:body) do
      {
        "type" => "object",
        "patternProperties" => {
          "*" => {
            "type" => "object",
            "properties" => {},
          },
        },
      }
    end

    let(:subschema) do
      Schema::EmbeddedSchema.new(
        "telephones",
        body,
        "parent_schema_id",
      )
    end
    let(:config) do
      {
        "schemas" => {
          "parent_schema_id" => {
            "subschemas" => {
              "telephones" => {
                "fields" => {
                  "video_relay_service" => {
                    "fields" => {
                      "prefix" => { "govspeak_enabled" => true },
                    },
                  },
                },
              },
            },
          },
        },
      }
    end

    let(:schema) { double(:schema, block_type: "schema") }
    let(:govspeak_enabled) { false }

    let(:field) do
      double(:field,
             name: "prefix",
             format: "string",
             enum_values: nil,
             default_value: "**Default** prefix: 18000 then",
             govspeak_enabled?: govspeak_enabled)
    end

    let(:field_value) { nil }

    let(:component) do
      described_class.new(
        edition: edition,
        field: field,
        schema:,
        value: field_value,
        nested_object_key: "video_relay_service",
        subschema: subschema,
      )
    end

    before do
      helper_stub = double(:helpers)
      allow_any_instance_of(Edition::Details::Fields::TextareaComponent).to receive(:helpers).and_return(helper_stub)
      allow(helper_stub).to receive(:hint_text).and_return(nil)
      allow(helper_stub).to receive(:humanized_label).and_return("Translated label")

      allow(Schema::EmbeddedSchema).to receive(:schema_settings).and_return(config)
    end

    describe "GovspeakEnabledTextareaComponent" do
      it "gives the textarea an ID describing path to field" do
        render_inline component

        expect(page).to have_css(COMPONENT_CLASS) do |component|
          gives_textarea_id_describing_path_to_field(component)
        end
      end

      it "includes a translated _label_" do
        render_inline component

        expect(page).to have_css(COMPONENT_CLASS) do |component|
          displays_label_using_translation_system(component)
        end
      end

      it "includes a _name_ attribute representing nested field location" do
        render_inline component

        expect(page).to have_css(COMPONENT_CLASS) do |component|
          sets_name_attribute_on_textarea_describing_nested_path_to_field(component)
        end
      end

      context "when there is an error on the field" do
        before do
          edition.errors.add(
            :details_telephones_video_relay_service_prefix,
            "blank",
          )

          expect(I18n).to receive(:t).with(
            "activerecord.errors.models.edition" \
              ".attributes.details_telephones_video_relay_service_prefix.format".to_sym,
            hash_including(message: "blank"),
          ).and_return("Prefix must be present")
        end

        it "adds an error class to the form group to highlight the area needing attention" do
          render_inline component

          expect(page).to have_css(COMPONENT_CLASS) do |component|
            expect(component).to have_css(".govuk-form-group.govuk-form-group--error")
          end
        end

        it "adds an error message to clarify the error and remedial action required" do
          render_inline component

          expect(page).to have_css(COMPONENT_CLASS) do |component|
            expect(component).to have_css(
              ".govuk-error-message",
              text: "Prefix must be present",
            )
          end
        end
      end

      describe "'Govspeak supported' indicator" do
        context "when the field IS declared as govspeak enabled" do
          let(:govspeak_enabled) { true }

          it "displays guidance to indicate 'Govspeak supported'" do
            render_inline component

            expect(page).to have_css(COMPONENT_CLASS) do |component|
              displays_indication_that_govspeak_is_supported(component)
            end
          end

          describe "hint ID mapping to textarea 'aria-describedby'" do
            let(:expected_hint_id_to_aria_mapping) do
              "edition_details_" \
                "telephones_video_relay_service_prefix-" \
                "hint"
            end

            it "includes an 'aria-describedby' attribute on the textarea, to match the label hint's ID" do
              render_inline component

              expect(page).to have_css(COMPONENT_CLASS) do |component|
                expect(component).to have_css(
                  "textarea[aria-describedby='#{expected_hint_id_to_aria_mapping}']",
                )
              end
            end

            it "includes a 'Preview' button" do
              render_inline component

              expect(page).to have_css(COMPONENT_CLASS) do |component|
                expect(component).to have_css(
                  "button.js-app-c-govspeak-editor__preview-button",
                  text: "Preview",
                )
              end
            end

            it "includes a 'Back to edit' button" do
              render_inline component

              expect(page).to have_css(COMPONENT_CLASS) do |component|
                expect(component).to have_css(
                  "button.js-app-c-govspeak-editor__back-button",
                  text: "Back to edit",
                )
              end
            end

            it "includes a preview element to be replaced by the Govspeak which JS will render into HTML" do
              render_inline component

              expect(page).to have_css(COMPONENT_CLASS) do |component|
                expect(component).to have_css(
                  ".app-c-govspeak-editor__preview.js-locale-switcher-custom p",
                  text: "Generating preview, please wait.",
                )
              end
            end
          end
        end

        context "when the field is NOT declared as govspeak enabled" do
          let(:govspeak_enabled) { false }

          it "does NOT display the 'Govspeak supported' hint" do
            render_inline component

            expect(page).to have_css(COMPONENT_CLASS) do |component|
              displays_no_indication_that_govspeak_is_supported(component)
            end
          end

          it "does NOT  include a 'Preview' button" do
            render_inline component

            expect(page).to have_css(COMPONENT_CLASS) do |component|
              component.assert_no_selector(
                "button.js-app-c-govspeak-editor__preview-button",
                text: "Preview",
              )
            end
          end

          it "does NOT include 'Back to edit' button" do
            render_inline component

            expect(page).to have_css(COMPONENT_CLASS) do |component|
              component.assert_no_selector(
                "button.js-app-c-govspeak-editor__back-button",
                text: "Back to edit",
              )
            end
          end

          it "does NOT include a preview element to be replaced by the rendered Govspeak" do
            render_inline component

            expect(page).to have_css(COMPONENT_CLASS) do |component|
              component.assert_no_selector(
                ".app-c-govspeak-editor__preview.js-locale-switcher-custom p",
                text: "Generating preview, please wait.",
              )
            end
          end
        end
      end
    end
  end

  def gives_textarea_id_describing_path_to_field(component)
    expected_id =
      "edition_details_telephones_video_relay_service_prefix"

    expect(component).to have_css(
      "textarea[id='#{expected_id}']",
    )
  end

  def displays_label_using_translation_system(component)
    expect(component).to have_css(
      "label",
      text: "Translated label",
    )
  end

  def sets_name_attribute_on_textarea_describing_nested_path_to_field(component)
    expected_name_attribute =
      "edition[details][telephones][video_relay_service][prefix]"

    expect(component).to have_css(
      "textarea[name='#{expected_name_attribute}']",
    )
  end

  def shows_default_value_in_textarea(component)
    expect(component).to have_css(
      "textarea",
      text: "**Default** prefix: 18000 then",
    )
  end

  def shows_set_value_in_textarea(component, value)
    expect(component).to have_css(
      "textarea",
      text: value,
    )
  end

  def displays_indication_that_govspeak_is_supported(component)
    expect(component).to have_css(
      ".guidance.govspeak-supported",
      text: "Govspeak supported",
    )
  end

  def displays_no_indication_that_govspeak_is_supported(component)
    component.assert_no_selector(
      ".guidance",
      text: "Govspeak supported",
    )
  end
end
