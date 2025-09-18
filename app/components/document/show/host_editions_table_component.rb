# frozen_string_literal: true

class Document::Show::HostEditionsTableComponent < ViewComponent::Base
  TABLE_ID = "host_editions"

  def initialize(caption:, host_content_items:, edition:, current_page: nil, order: nil)
    @caption = caption
    @host_content_items = host_content_items
    @current_page = current_page.presence || 1
    @order = order.presence || HostContentItem::DEFAULT_ORDER
    @edition = edition
  end

  def current_page
    @current_page.to_i
  end

  def total_pages
    host_content_items.total_pages.to_i
  end

  def base_pagination_path
    "#{request.url}##{TABLE_ID}"
  end

private

  attr_reader :caption, :host_content_items, :order, :edition

  def head
    [
      {
        text: "Title",
        href: sort_link("title"),
        sort_direction: sort_direction("title"),
      },
      {
        text: "Type",
        href: sort_link("document_type"),
        sort_direction: sort_direction("document_type"),
      },
      {
        text: "Views (30 days)",
        href: sort_link("unique_pageviews"),
        sort_direction: sort_direction("unique_pageviews"),
      },
      {
        text: "Instances",
        href: sort_link("instances"),
        sort_direction: sort_direction("instances"),
      },
      {
        text: "Lead organisation",
        href: sort_link("primary_publishing_organisation_title"),
        sort_direction: sort_direction("primary_publishing_organisation_title"),
      },
      {
        text: "Last updated",
        href: sort_link("last_edited_at"),
        sort_direction: sort_direction("last_edited_at"),
      },
    ].compact
  end

  def rows
    return [] unless host_content_items

    host_content_items.map do |content_item|
      row_for_content_item(content_item)
    end
  end

  def row_for_content_item(content_item)
    [
      title_row(content_item),
      {
        text: content_item.document_type.humanize,
      },
      {
        text: content_item.unique_pageviews ? number_to_human(content_item.unique_pageviews, format: "%n%u", precision: 3, significant: true, units: { thousand: "k", million: "m", billion: "b" }) : 0,
      },
      {
        text: content_item.instances,
      },
      {
        text: content_item.publishing_organisation.fetch("title", nil),
      },
      {
        text: updated_field_for(content_item),
      },
    ].compact
  end

  def sort_direction(param)
    case order
    when param
      "ascending"
    when "-#{param}"
      "descending"
    end
  end

  def sort_link(param)
    if sort_direction(param) == "ascending"
      param = "-#{param}"
    end
    helpers.url_for(only_path: false, params: { order: param }, anchor: TABLE_ID)
  end

  def frontend_path(content_item)
    return nil if content_item.base_path.nil?

    Plek.website_root + content_item.base_path
  end

  def title_row(content_item)
    {
      text: content_link(content_item),
    }
  end

  def content_link_text(content_item)
    sanitize [
      content_item.title,
      tag.span("(opens in new tab)", class: "govuk-visually-hidden"),
    ].join(" ")
  end

  def content_link(content_item)
    path = frontend_path(content_item)

    if path
      link_to(content_link_text(content_item), path, class: "govuk-link", target: "_blank", rel: "noopener")
    else
      content_item.title
    end
  end

  def updated_field_for(content_item)
    user_copy = if content_item.last_edited_by_editor
                  link_to(
                    content_item.last_edited_by_editor.name,
                    helpers.user_path(content_item.last_edited_by_editor.uid), { class: "govuk-link" }
                  )
                else
                  "Unknown user"
                end
    "#{time_ago_in_words(content_item.last_edited_at)} ago by #{user_copy}".html_safe
  end
end
