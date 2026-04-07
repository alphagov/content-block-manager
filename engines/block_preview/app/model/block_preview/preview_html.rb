require "net/http"
require "json"
require "uri"

module BlockPreview
  class PreviewHtml
    include BlockPreview::Engine.routes.url_helpers

    ERROR_HTML = "<html><head></head><body><p>Preview not found</p></body></html>".freeze

    class HtmlSnapshotError < StandardError; end

    def initialize(content_id:, block:, base_path:, locale:, state:, auth_bypass_id:)
      @content_id = content_id
      @block = block
      @base_path = base_path
      @state = state
      @locale = locale
      @auth_bypass_id = auth_bypass_id
    end

    def to_s
      uri = Addressable::URI.parse(frontend_path)
      nokogiri_html = html_snapshot_from_frontend(uri)
      add_draft_style(nokogiri_html)
      update_css_hrefs(nokogiri_html)
      update_js_srcs(nokogiri_html)
      add_nokodiff_stylesheet(nokogiri_html)
      update_preview_with_diff(nokogiri_html)
      update_local_link_paths(nokogiri_html)
      update_local_form_actions(nokogiri_html, uri.scheme, uri.host)
      nokogiri_html.to_s
    rescue HtmlSnapshotError
      ERROR_HTML
    end

  private

    attr_reader :block, :content_id, :base_path, :locale, :state, :auth_bypass_id

    def frontend_path
      frontend_base_path + base_path
    end

    def frontend_base_path
      @frontend_base_path ||= Rails.env.development? ? development_base_path : website_base_root
    end

    def website_base_root
      draft? ? Plek.external_url_for("draft-origin") : Plek.website_root
    end

    # There are multiple rendering apps for GOV.UK. In non-dev environments, the Router app determines the rendering app
    # to use. We don't have access to this in dev, so we need to get the rendering app from the Publishing API and construct
    # the base path that way.
    def development_base_path
      @development_base_path ||= begin
        publishing_api_response ||= Public::Services.publishing_api.get_content(content_id)
        Plek.external_url_for(rendering_app(publishing_api_response))
      end
    end

    def rendering_app(publishing_api_response)
      rendering_app = publishing_api_response["rendering_app"] || "frontend"
      if rendering_app == "smartanswers"
        # Smart Answers doesn't have a separate draft app, so we return the same app regardless of the state
        "smart-answers"
      else
        draft? ? "draft-#{rendering_app}" : rendering_app
      end
    end

    def draft?
      state == "draft"
    end

    def html_snapshot_from_frontend(uri)
      uri = add_auth_bypass_token_to_uri(uri) if draft?
      response = Net::HTTP.get_response(uri)
      if response.code == "200"
        Nokogiri::HTML.parse(response.body)
      else
        raise HtmlSnapshotError
      end
    end

    def add_auth_bypass_token_to_uri(uri)
      uri.query_values = (uri.query_values || {}).merge({ token: auth_bypass_token })
      uri
    end

    def update_local_link_paths(nokogiri_html)
      url = host_content_preview_path(edition_id: block.id, host_content_id: content_id, locale:, state:)
      nokogiri_html.css("a").each do |link|
        next if link[:href].start_with?("//") || link[:href].start_with?("http")

        link[:href] = "#{url}&base_path=#{link[:href]}"
        link[:target] = "_parent"
      end

      nokogiri_html
    end

    def update_local_form_actions(nokogiri_html, scheme, host)
      url = host_content_preview_form_handler_path(edition_id: block.id, host_content_id: content_id, locale:)
      nokogiri_html.css("main form").each do |form|
        form[:action] = "#{url}&url=#{scheme}://#{host}#{form[:action]}&method=#{form[:method]}"
        form[:target] = "_parent"
        form[:method] = "post"
        form.css("input").each do |input|
          input[:name] = "body[#{input[:name]}]"
        end
      end

      nokogiri_html
    end

    def add_draft_style(nokogiri_html)
      nokogiri_html.css("body").each do |body|
        body["class"] ||= ""
        body["class"] += " gem-c-layout-for-public--draft"
      end
      nokogiri_html
    end

    def update_css_hrefs(nokogiri_html)
      head = nokogiri_html.at_css("head")
      head.css("link[rel='stylesheet']").each do |link|
        link[:href] = frontend_base_path + link[:href] if link[:href]
      end
      nokogiri_html
    end

    def update_js_srcs(nokogiri_html)
      head = nokogiri_html.at_css("head")
      head.css("script").each do |script|
        script[:src] = frontend_base_path + script[:src] if script[:src]
      end
      nokogiri_html
    end

    def update_preview_with_diff(nokogiri_html)
      nokogiri_html.at_css("[data-module=\"govspeak\"]")
                   .replace(
                     BlockPreview::ContentDiff.new(nokogiri_html, block).to_s,
                   )

      nokogiri_html
    end

    def add_nokodiff_stylesheet(nokogiri_html)
      head = nokogiri_html.at_css("head")
      return nokogiri_html unless head

      href = nokodiff_stylesheet_href
      return nokogiri_html if head.at_css("link[rel='stylesheet'][href='#{href}']")

      head.add_child(Nokogiri::HTML::DocumentFragment.parse(%(<link rel="stylesheet" href="#{href}">)))
      nokogiri_html
    end

    def nokodiff_stylesheet_href
      ActionController::Base.helpers.asset_path("nokodiff.css")
    end

    def auth_bypass_token
      JWT.encode(
        {
          "sub" => auth_bypass_id,
          "content_id" => content_id,
          "iat" => Time.zone.now.to_i,
          "exp" => bypass_token_expiry_date.to_i,
        },
        ENV["AUTHENTICATING_PROXY_JWT_AUTH_SECRET"],
        "HS256",
      )
    end

    def bypass_token_expiry_date
      7.days.from_now
    end
  end
end
