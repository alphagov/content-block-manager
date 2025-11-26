RSpec.describe Document::Show::HostEditionsTableComponent, type: :component do
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::DateHelper

  let(:described_class) { Document::Show::HostEditionsTableComponent }
  let(:caption) { "Some caption" }
  let(:publishing_organisation) do
    {
      "content_id" => SecureRandom.uuid,
      "title" => "bar",
      "base_path" => "/bar",
    }
  end
  let(:unique_pageviews) { 1_200_000 }

  let(:last_edited_by_editor) { build(:signon_user) }
  let(:host_content_item) do
    HostContentItem.new(
      "title" => "Some title",
      "base_path" => "/foo",
      "document_type" => "document_type",
      "publishing_app" => "publisher",
      "last_edited_by_editor" => last_edited_by_editor,
      "last_edited_at" => Time.zone.now.to_s,
      "publishing_organisation" => publishing_organisation,
      "unique_pageviews" => unique_pageviews,
      "host_content_id" => SecureRandom.uuid,
      "host_locale" => "en",
      "instances" => 1,
    )
  end
  let(:host_content_items) do
    build(
      :host_content_items,
      items: [host_content_item],
      total: 20,
      total_pages: 2,
    )
  end

  let(:edition) do
    build(:edition, :pension, state: "published", id: SecureRandom.uuid)
  end

  let(:in_progress_edition) do
    build(:edition, :pension, state: "draft", id: SecureRandom.uuid)
  end
  def self.it_returns_unknown_user
    it "returns Unknown user" do
      render_inline(
        described_class.new(
          caption:,
          host_content_items:,
          edition:,
        ),
      )

      expect(page).to have_css "tbody .govuk-table__cell", text: "#{time_ago_in_words(host_content_item.last_edited_at)} ago by Unknown user"
    end
  end

  around do |test|
    with_request_url root_path do
      test.call
    end
  end

  describe "table component" do
    it "renders embedded editions" do
      render_inline(
        described_class.new(
          caption:,
          host_content_items:,
          edition:,
        ),
      )

      expect(page).to have_css ".govuk-table__caption", text: caption

      headers = page.find_all(".govuk-table__header")

      expect(headers.count).to eq(6)

      expect(headers[0]).to have_text "Title"
      expect(headers[1]).to have_text "Type"
      expect(headers[2]).to have_text "Instances"
      expect(headers[3]).to have_text "Views (30 days)"
      expect(headers[4]).to have_text "Lead organisation"
      expect(headers[5]).to have_text "Last updated"

      rows = page.find_all("tbody .govuk-table__row")

      expect(rows.count).to eq(1)

      columns = rows[0].find_all(".govuk-table__cell")

      expect(columns.count).to eq(6)

      expect(columns[0]).to have_css ".govuk-link" do |link|
        expect(link.text).to eq("#{host_content_item.title} (opens in new tab)")
        expect(link[:href]).to eq(Plek.website_root + host_content_item.base_path)
        expect(link[:rel]).to eq("noopener")
        expect(link[:target]).to eq("_blank")
      end

      expect(columns[1]).to have_text host_content_item.document_type.humanize
      expect(columns[2]).to have_text "1"
      expect(columns[3]).to have_text "1.2m"
      expect(columns[4]).to have_text host_content_item.publishing_organisation["title"]

      expect(columns[5]).to have_text "#{time_ago_in_words(host_content_item.last_edited_at)} ago by #{last_edited_by_editor.name}"

      expect(columns[5]).to have_css "a.govuk-link" do |link|
        expect(link.text).to eq(last_edited_by_editor.name)
        expect(link[:href]).to eq(user_path(last_edited_by_editor.uid))
      end
    end

    context "when the organisation received does not have a title or base_path" do
      let(:publishing_organisation) do
        {
          "content_id" => SecureRandom.uuid,
          "title" => nil,
          "base_path" => nil,
        }
      end

      it "presents 'Not set'" do
        render_inline(
          described_class.new(
            caption:,
            host_content_items:,
            edition:,
          ),
        )

        expect(page).to have_css "tbody .govuk-table__cell", text: "Not set"
      end
    end

    context "when last_edited_by_editor is nil" do
      let(:last_edited_by_editor) { nil }

      it_returns_unknown_user
    end

    context "when unique pageviews can't be found" do
      let(:unique_pageviews) { nil }

      it "displays a zero" do
        render_inline(
          described_class.new(
            caption:,
            host_content_items:,
            edition:,
          ),
        )

        expect(page).to have_css "tbody .govuk-table__cell", text: "0"
      end
    end

    describe "when a base_path is nil" do
      let(:host_content_item) do
        HostContentItem.new(
          "title" => "Some title",
          "base_path" => nil,
          "document_type" => "document_type",
          "publishing_app" => "publisher",
          "last_edited_by_editor" => last_edited_by_editor,
          "last_edited_at" => Time.zone.now.to_s,
          "publishing_organisation" => publishing_organisation,
          "unique_pageviews" => unique_pageviews,
          "host_content_id" => SecureRandom.uuid,
          "host_locale" => "en",
          "instances" => 1,
        )
      end

      it "Does not render a link" do
        render_inline(
          described_class.new(
            caption:,
            host_content_items:,
            edition:,
          ),
        )

        expect(page).to have_css "tbody" do |tbody|
          tbody.assert_no_selector ".govuk-link", text: host_content_item.title.to_s
        end
      end
    end

    describe "sorting headers" do
      it "adds the table header as an anchor tag to each header" do
        render_inline(
          described_class.new(
            caption:,
            host_content_items:,
            edition:,
          ),
        )

        expect(page).to have_css "a.app-table__sort-link[href*='##{Document::Show::HostEditionsTableComponent::TABLE_ID}']", count: 6
      end

      it "shows all the headers unordered by default" do
        render_inline(
          described_class.new(
            caption:,
            host_content_items:,
            edition:,
          ),
        )

        expect(page).to have_css "a.app-table__sort-link[href*='order=title']", text: "Title"
        expect(page).to have_css "a.app-table__sort-link[href*='order=document_type']", text: "Type"
        expect(page).to have_css "a.app-table__sort-link[href*='order=instances']", text: "Instances"
        expect(page).to have_css "a.app-table__sort-link[href*='order=unique_pageviews']", text: "Views (30 days)"
        expect(page).to have_css "a.app-table__sort-link[href*='order=primary_publishing_organisation_title']", text: "Lead organisation"
        expect(page).to have_css "a.app-table__sort-link[href*='order=last_edited_at']", text: "Last updated"

        expect(page).to have_css ".govuk-table__header--active a", text: "Views (30 days)"
      end

      %w[title document_type unique_pageviews primary_publishing_organisation_title last_edited_at instances].each do |order|
        it "shows the link as selected when #{order} is in ascending order" do
          render_inline(
            described_class.new(
              caption:,
              host_content_items:,
              order:,
              edition:,
            ),
          )

          expect(page).to have_css ".govuk-table__header--active a.app-table__sort-link.app-table__sort-link--ascending[href*='order=-#{order}']"
        end

        it "shows the link as selected when #{order} is in descending order" do
          render_inline(
            described_class.new(
              caption:,
              host_content_items:,
              order: "-#{order}",
              edition:,
            ),
          )

          expect(page).to have_css ".govuk-table__header--active a.app-table__sort-link.app-table__sort-link--descending[href*='order=#{order}']"
        end
      end
    end

    describe "pagination" do
      context "when there is only one page" do
        let(:host_content_items) do
          build(
            :host_content_items,
            items: [host_content_item],
            total: 1,
            total_pages: 1,
          )
        end

        it "does not show pagination" do
          render_inline(
            described_class.new(
              caption:,
              host_content_items:,
              edition:,
            ),
          )

          expect(page).not_to have_css ".govuk-pagination__list"
        end
      end

      context "when there is more than one page" do
        let(:host_content_items) do
          build(
            :host_content_items,
            items: [host_content_item],
            total: 20,
            total_pages: 2,
          )
        end

        it "adds the table header as an anchor tag to each pagination link" do
          render_inline(
            described_class.new(
              caption:,
              host_content_items:,
              edition:,
            ),
          )

          expect(page).to have_css "ul.govuk-pagination__list a.govuk-pagination__link[href*='##{Document::Show::HostEditionsTableComponent::TABLE_ID}']", count: 2
          expect(page).to have_css ".govuk-pagination__next a.govuk-pagination__link[href*='##{Document::Show::HostEditionsTableComponent::TABLE_ID}']"
        end

        it "shows the first page as selected by default" do
          render_inline(
            described_class.new(
              caption:,
              host_content_items:,
              edition:,
            ),
          )

          expect(page).to have_css ".govuk-pagination__list"
          expect(page).to have_css "a.govuk-pagination__link[aria-current='page']", text: "1"
        end

        it "shows the currently selected page" do
          render_inline(
            described_class.new(
              caption:,
              host_content_items:,
              current_page: 2,
              edition:,
            ),
          )

          expect(page).to have_css "a.govuk-pagination__link[aria-current='page']", text: "2"
        end
      end
    end
  end

  describe "in progress table component" do
    it "renders embedded editions" do
      render_inline(
        described_class.new(
          caption:,
          host_content_items:,
          edition: in_progress_edition,
        ),
      )

      expect(page).to have_css ".govuk-table__caption", text: caption

      headers = page.find_all(".govuk-table__header")

      expect(headers.count).to eq(7)

      expect(headers[0]).to have_text "Title"
      expect(headers[1]).to have_text "Type"
      expect(headers[2]).to have_text "Instances"
      expect(headers[3]).to have_text "Views (30 days)"
      expect(headers[4]).to have_text "Lead organisation"
      expect(headers[5]).to have_text "Last updated"
      expect(headers[6]).to have_text "Preview (opens in new tab)"

      rows = page.find_all("tbody .govuk-table__row")

      expect(rows.count).to eq(1)

      columns = rows[0].find_all(".govuk-table__cell")

      expect(columns.count).to eq(7)

      expect(columns[0]).to have_no_css ".govuk-link" do |link|
      end

      expect(columns[1]).to have_text host_content_item.document_type.humanize
      expect(columns[2]).to have_text "1"
      expect(columns[3]).to have_text "1.2m"
      expect(columns[4]).to have_text host_content_item.publishing_organisation["title"]

      expect(columns[5]).to have_text "#{time_ago_in_words(host_content_item.last_edited_at)} ago by #{last_edited_by_editor.name}"

      expect(columns[5]).to have_css "a.govuk-link" do |link|
        expect(link.text).to eq(last_edited_by_editor.name)
        expect(link[:href]).to eq(user_path(last_edited_by_editor.uid))
      end

      expect(columns[6]).to have_text "Preview #{host_content_item.title} (opens in new tab)"

      expect(columns[6]).to have_css "a.govuk-link" do |link|
        expect(link.text).to eq("Preview #{host_content_item.title} (opens in new tab)")
        expect(link[:href]).to include("/preview")
      end
    end
  end
end
