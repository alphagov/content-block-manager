RSpec.describe Shared::EmbeddedObjects::SummaryCard::NestedItemComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:field_name) { "nested_item_field" }
  let(:field_value) { "field *value*" }
  let(:govspeak_formatted_value) { "GOVSPEAK FORMATTED VALUE" }

  let(:nested_field) { build(:field, name: field_name, govspeak_enabled?: govspeak_enabled, label: "Field") }
  let(:field) { build(:field, name: "nested_object", title: "Nested object") }
  let(:govspeak_enabled) { false }
  let(:items_counter) { nil }

  let(:nested_items) do
    { field_name => field_value }
  end

  let(:schema) do
    double(
      "sub-schema",
      name: "schema",
    )
  end

  let(:root_schema_name) { "schema" }

  let(:component) do
    Shared::EmbeddedObjects::SummaryCard::NestedItemComponent.new(
      items: nested_items,
      field:,
      items_counter:,
    )
  end

  before do
    allow(field).to receive(:nested_field).with(field_name).and_return(nested_field)
    allow(component).to receive(:render_govspeak).with(field_value).and_return(govspeak_formatted_value)
  end

  it "shows the field title and nested labels" do
    render_inline component

    expect(page).to have_css(".govuk-summary-card__title", text: "Nested object")
    expect(page).to have_css("dt.govuk-summary-list__key", text: "Field")
  end

  context "when the counter is present" do
    let(:items_counter) { 2 }

    it "appends a counter to the title" do
      render_inline component

      expect(page).to have_css(".govuk-summary-card__title", text: "Nested object 3")
    end
  end

  describe "when the field supports govspeak" do
    let(:govspeak_enabled) { true }

    it "renders the value as HTML" do
      render_inline component
      rendered_value = page.find("dt.govuk-summary-list__value").native.children.to_html.strip

      expect(rendered_value).to eq(govspeak_formatted_value)

      expect(component).to have_received(:render_govspeak).with(field_value)
    end
  end

  describe "when the field does not support govspeak" do
    let(:govspeak_enabled) { false }

    it "renders the value as plain text" do
      render_inline component
      rendered_value = page.find("dt.govuk-summary-list__value").native.children.to_html.strip

      expect(rendered_value).to eq(field_value)

      expect(component).to_not have_received(:render_govspeak).with(field_value)
    end
  end

  describe "when the nested field is an object" do
    let(:name_field) { build(:field, name: "name", label: "Name") }
    let(:email_field) { build(:field, name: "email", label: "Email") }

    let(:nested_items) do
      {
        field_name => {
          name_field.name => "Someone",
          email_field.name => "foo@example.com",
        },
      }
    end

    before do
      allow(nested_field).to receive(:nested_field).with(name_field.name).and_return(name_field)
      allow(nested_field).to receive(:nested_field).with(email_field.name).and_return(email_field)
    end

    it "renders a nested summary card" do
      render_inline component

      expect(page).to have_css(".govuk-summary-card__title", text: "Nested object")
      expect(page).to have_css(".gem-c-summary__block") do |block|
        expect(block).to have_css(".govuk-summary-list__row", text: /#{name_field.label}/) do |row|
          expect(row).to have_css(".govuk-summary-list__key", text: name_field.label)
          expect(row).to have_css(".govuk-summary-list__value", text: "Someone")
        end

        expect(block).to have_css(".govuk-summary-list__row", text: /#{email_field.label}/) do |row|
          expect(row).to have_css(".govuk-summary-list__key", text: email_field.label)
          expect(row).to have_css(".govuk-summary-list__value", text: "foo@example.com")
        end
      end
    end
  end

  describe "when there is an object embedded in the nested field" do
    let(:title_field) { build(:field, name: "title", label: "Title") }
    let(:person_field) { build(:field, name: "person", title: "Person") }
    let(:name_field) { build(:field, name: "name", label: "Name") }
    let(:email_field) { build(:field, name: "email", label: "Email") }

    let(:nested_items) do
      {
        field_name => {
          title_field.name => "Nested object",
          person_field.name => {
            name_field.name => "Someone",
            email_field.name => "foo@example.com",
          },
        },
      }
    end

    before do
      allow(nested_field).to receive(:nested_field).with(title_field.name).and_return(title_field)
      allow(nested_field).to receive(:nested_field).with(person_field.name).and_return(person_field)
      allow(person_field).to receive(:nested_field).with(name_field.name).and_return(name_field)
      allow(person_field).to receive(:nested_field).with(email_field.name).and_return(email_field)
    end

    it "renders a nested summary card" do
      render_inline component

      expect(page).to have_css(".govuk-summary-card__title", text: "Nested object")
      expect(page).to have_css(".gem-c-summary__block") do |block|
        expect(block).to have_css(".govuk-summary-list__row", text: /#{title_field.label}/) do |row|
          expect(row).to have_css(".govuk-summary-list__key", text: title_field.label)
          expect(row).to have_css(".govuk-summary-list__value", text: "Nested object")
        end

        expect(block).to have_css(".gem-c-summary__block") do |nested_block|
          expect(nested_block).to have_css(".govuk-summary-card__title", text: person_field.title)

          expect(nested_block).to have_css(".govuk-summary-list__row", text: /#{name_field.label}/) do |row|
            expect(row).to have_css(".govuk-summary-list__key", text: name_field.label)
            expect(row).to have_css(".govuk-summary-list__value", text: "Someone")
          end

          expect(nested_block).to have_css(".govuk-summary-list__row", text: /#{email_field.label}/) do |row|
            expect(row).to have_css(".govuk-summary-list__key", text: email_field.label)
            expect(row).to have_css(".govuk-summary-list__value", text: "foo@example.com")
          end
        end
      end
    end
  end

  describe "when there is an array embedded in the nested field" do
    let(:title_field) { build(:field, name: "title", label: "Title") }
    let(:people_field) { build(:field, name: "person", title: "Person") }
    let(:name_field) { build(:field, name: "name", label: "Name") }
    let(:email_field) { build(:field, name: "email", label: "Email") }

    let(:nested_items) do
      {
        field_name => {
          title_field.name => "Nested object",
          people_field.name => [
            {
              name_field.name => "First person",
              email_field.name => "person1@example.com",
            },
            {
              name_field.name => "Second person",
              email_field.name => "person2@example.com",
            },
          ],
        },
      }
    end

    before do
      allow(nested_field).to receive(:nested_field).with(title_field.name).and_return(title_field)
      allow(nested_field).to receive(:nested_field).with(people_field.name).and_return(people_field)
      allow(people_field).to receive(:nested_field).with(name_field.name).and_return(name_field)
      allow(people_field).to receive(:nested_field).with(email_field.name).and_return(email_field)
    end

    it "renders a nested summary card" do
      render_inline component

      expect(page).to have_css(".govuk-summary-card__title", text: "Nested object")
      expect(page).to have_css(".gem-c-summary__block") do |block|
        expect(block).to have_css(".govuk-summary-list__row", text: /#{title_field.label}/) do |row|
          expect(row).to have_css(".govuk-summary-list__key", text: title_field.label)
          expect(row).to have_css(".govuk-summary-list__value", text: "Nested object")
        end

        expect(block).to have_css(".gem-c-summary__block") do |nested_block|
          expect(nested_block).to have_css(".gem-c-summary-card", text: /Person 1/) do |person_1_block|
            expect(person_1_block).to have_css(".govuk-summary-card__title", text: "Person 1")

            expect(person_1_block).to have_css(".govuk-summary-list__row", text: /#{name_field.label}/) do |row|
              expect(row).to have_css(".govuk-summary-list__key", text: name_field.label)
              expect(row).to have_css(".govuk-summary-list__value", text: "First person")
            end

            expect(person_1_block).to have_css(".govuk-summary-list__row", text: /#{email_field.label}/) do |row|
              expect(row).to have_css(".govuk-summary-list__key", text: email_field.label)
              expect(row).to have_css(".govuk-summary-list__value", text: "person1@example.com")
            end
          end

          expect(nested_block).to have_css(".gem-c-summary-card", text: /Person 2/) do |person_2_block|
            expect(person_2_block).to have_css(".govuk-summary-card__title", text: "Person 2")

            expect(person_2_block).to have_css(".govuk-summary-list__row", text: /#{name_field.label}/) do |row|
              expect(row).to have_css(".govuk-summary-list__key", text: name_field.label)
              expect(row).to have_css(".govuk-summary-list__value", text: "Second person")
            end

            expect(person_2_block).to have_css(".govuk-summary-list__row", text: /#{email_field.label}/) do |row|
              expect(row).to have_css(".govuk-summary-list__key", text: email_field.label)
              expect(row).to have_css(".govuk-summary-list__value", text: "person2@example.com")
            end
          end
        end
      end
    end
  end
end
