require "delegate"

module GovspeakPreviewHelper
  include Rails.application.routes.url_helpers

  def govspeak_to_html(govspeak, options = {})
    processed_govspeak = preprocess_govspeak(govspeak, options)
    html = markup_to_nokogiri_doc(
      processed_govspeak,
      locale: options[:locale],
    ).to_html

    "<div class=\"govspeak\">#{html}</div>".html_safe
  end

  def govspeak_headers(govspeak, level = (2..2))
    build_govspeak_document(govspeak).headers.select do |header|
      level.cover?(header.level)
    end
  end

  def govspeak_header_hierarchy(govspeak)
    headers = []
    govspeak_headers(govspeak, 2..3).each do |header|
      case header.level
      when 2
        headers << { header:, children: [] }
      when 3
        raise Govspeak::OrphanedHeadingError, header.text if headers.none?

        headers.last[:children] << header
      end
    end
    headers
  end

  def preprocess_govspeak(govspeak, options)
    govspeak ||= ""
    ContentBlockManager::FindAndReplaceEmbedCodesService.call(govspeak) if options[:preview]
    govspeak = add_heading_numbers(govspeak) if options[:heading_numbering] == :auto
    govspeak
  end

private

  def add_heading_numbers(govspeak)
    h2 = 0
    h3 = 0

    govspeak.gsub(/^(###|##)\s*(.+)$/) do
      hashes = Regexp.last_match(1)
      heading_text = Regexp.last_match(2).strip

      if hashes == "##"
        h2 += 1
        h3 = 0
        num = "#{h2}."
      else # "###"
        h2 = 1 if h2.zero?
        h3 += 1
        num = "#{h2}.#{h3}"
      end

      # We have to manually derive and append a slug otherwise when Govspeak
      # generates the HTML, it includes the <span> and number in the ID. Hence
      # the `heading_text.parameterize`
      "#{hashes} <span class=\"number\">#{num} </span>#{heading_text} {##{heading_text.parameterize}}"
    end
  end

  def markup_to_nokogiri_doc(govspeak, options = {})
    govspeak = build_govspeak_document(govspeak, options)
    doc = Nokogiri::HTML::Document.new
    doc.encoding = "UTF-8"
    doc.fragment(govspeak.to_html)
  end

  def build_govspeak_document(govspeak, options = {})
    locale = options[:locale]

    Govspeak::Document.new(
      govspeak,
      images: [],
      attachments: [],
      document_domains: [
        ContentBlockManager.admin_host,
        ContentBlockManager.public_host,
      ],
      locale:,
    )
  end
end
