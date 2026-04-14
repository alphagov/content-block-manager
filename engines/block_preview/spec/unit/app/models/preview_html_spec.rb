RSpec.describe BlockPreview::PreviewHtml do
  include BlockPreview::Engine.routes.url_helpers

  let(:host_content_id) { SecureRandom.uuid }
  let(:preview_content_id) { SecureRandom.uuid }
  let(:host_title) { "Test" }
  let(:host_base_path) { "/test" }
  let(:uri_mock) { double }

  let(:fake_content) do
    <<-HTML
    <div class=\"govuk-body\">
        <p>test</p>
        <span
          class=\"content-embed content-embed__content_block_contact\"
          data-content-block=\"\"
          data-document-type=\"content_block_contact\"
          data-embed-code=\"embed-code\"
          data-content-id=\"#{preview_content_id}\">example@example.com</span>
    </div>
    HTML
  end

  let(:fake_body) do
    <<-HTML
      <head>
        <link rel="stylesheet" href="/assets/application.css">
        <script src="/assets/application.js"></script>/
      </head>
      <body class="govuk-body">
        <div data-module=\"govspeak\">
          #{fake_content}
        </div>
      </body>
    HTML
  end

  let(:fake_frontend_response) do
    instance_double(
      "Net::HTTPResponse",
      code: "200",
      body: fake_body,
    )
  end

  let(:block_render) do
    "<span class=\"content-embed content-embed__content_block_contact\" data-content-block=\"\" data-document-type=\"content_block_contact\" data-embed-code=\"embed-code\" data-content-id=\"#{preview_content_id}\"><a class=\"govuk-link\" href=\"mailto:new@new.com\">new@new.com</a></span>"
  end

  let(:document) do
    build(:document, :contact, content_id: preview_content_id)
  end

  let(:block_to_preview) do
    build(:content_block, edition: build_stubbed(:edition, document:))
  end

  let(:auth_bypass_id) { SecureRandom.uuid }
  let(:token) { "token" }
  let(:content_diff_spy) { double("BlockPreview::ContentDiff", to_s: fake_content) }

  before do
    allow(JWT).to receive(:encode).and_return(token)
    allow(Net::HTTP).to receive(:get_response).and_return(fake_frontend_response)
    allow(BlockPreview::ContentDiff).to receive(:new).and_return(content_diff_spy)
  end

  it "makes a request to the frontend" do
    BlockPreview::PreviewHtml.new(
      content_id: host_content_id,
      block: block_to_preview,
      base_path: host_base_path,
      locale: "en",
      state: "published",
      auth_bypass_id:,
    ).to_s

    expect(Net::HTTP).to have_received(:get_response) do |url|
      expect(url.host).to eq(Plek.website_root.sub("http://", ""))
      expect(url.path).to eq(host_base_path)
    end
  end

  it "does not append a token to the url" do
    BlockPreview::PreviewHtml.new(
      content_id: host_content_id,
      block: block_to_preview,
      base_path: host_base_path,
      locale: "en",
      state: "published",
      auth_bypass_id:,
    ).to_s

    expect(Net::HTTP).to have_received(:get_response) do |url|
      expect(url.query).to be_nil
    end
  end

  it "returns the preview html" do
    actual_content = BlockPreview::PreviewHtml.new(
      content_id: host_content_id,
      block: block_to_preview,
      base_path: host_base_path,
      locale: "en",
      state: "published",
      auth_bypass_id:,
    ).to_s

    parsed_content = Nokogiri::HTML.parse(actual_content)

    expect(parsed_content.at_css("body.gem-c-layout-for-public--draft")).to be_present
    expect(BlockPreview::ContentDiff).to have_received(:new).with(
      anything,
      block_to_preview,
    )
    expect(content_diff_spy).to have_received(:to_s)
  end

  it "appends the base path to the CSS and JS references" do
    actual_content = BlockPreview::PreviewHtml.new(
      content_id: host_content_id,
      block: block_to_preview,
      base_path: host_base_path,
      locale: "en",
      state: "published",
      auth_bypass_id:,
    ).to_s

    parsed_content = Nokogiri::HTML.parse(actual_content)

    expect(parsed_content.at_css("link[href='#{Plek.website_root}/assets/application.css']")).to be_present
    expect(parsed_content.at_css("script[src='#{Plek.website_root}/assets/application.js']")).to be_present
  end

  it "injects the nokodiff stylesheet from the local asset pipeline" do
    actual_content = BlockPreview::PreviewHtml.new(
      content_id: host_content_id,
      block: block_to_preview,
      base_path: host_base_path,
      locale: "en",
      state: "published",
      auth_bypass_id:,
    ).to_s

    parsed_content = Nokogiri::HTML.parse(actual_content)
    hrefs = parsed_content.css("head link[rel='stylesheet']").map { |link| link["href"] }

    expect(hrefs).to include("/assets/content-block-manager/nokodiff.css")
  end

  describe "when the frontend returns a non-200 response" do
    let(:fake_frontend_response) do
      instance_double(
        "Net::HTTPResponse",
        code: "500",
      )
    end

    it "shows an error template" do
      actual_content = BlockPreview::PreviewHtml.new(
        content_id: host_content_id,
        block: block_to_preview,
        base_path: host_base_path,
        locale: "en",
        state: "published",
        auth_bypass_id:,
      ).to_s

      expect(actual_content).to eq(BlockPreview::PreviewHtml::ERROR_HTML)
    end
  end

  describe "when the frontend response contains links" do
    let(:fake_content) do
      "
        <a href='/foo'>Internal link</a>
        <a href='https://example.com'>External link</a>
        <a href='//example.com'>Protocol relative link</a>
      "
    end

    let(:actual_content) do
      BlockPreview::PreviewHtml.new(
        content_id: host_content_id,
        block: block_to_preview,
        base_path: host_base_path,
        locale: "en",
        state:,
        auth_bypass_id:,
      ).to_s
    end

    let(:parsed_content) { Nokogiri::HTML.parse(actual_content) }
    let(:preview_path) { host_content_preview_path(edition_id: block_to_preview.id, host_content_id:) }

    let(:internal_link) { parsed_content.xpath("//a")[0] }
    let(:internal_link_url) { URI.parse(internal_link.attribute("href").to_s) }
    let(:internal_link_query_hash) { Rack::Utils.parse_query(internal_link_url.query) }

    context "when the state is published" do
      let(:state) { "published" }

      describe "internal links" do
        it "updates the internal link path to include the preview path" do
          expect(internal_link_url.path).to eq(preview_path)
        end

        it "represents the target state with url param" do
          expect(internal_link_query_hash["state"]).to eq("published")
        end

        it "represents the target locale with url param" do
          expect(internal_link_query_hash["locale"]).to eq("en")
        end

        it "represents the target base path with url param" do
          expect(internal_link_query_hash["base_path"]).to eq("/foo")
        end

        it "updates the target attribute to _parent" do
          expect(internal_link.attribute("target").to_s).to eq("_parent")
        end
      end

      it "leaves external link paths untouched" do
        external_link = parsed_content.xpath("//a")[1]
        protocol_relative_link = parsed_content.xpath("//a")[2]

        expect(external_link.attribute("href").to_s).to eq("https://example.com")
        expect(protocol_relative_link.attribute("href").to_s).to eq("//example.com")
      end
    end

    context "when the state is draft" do
      let(:state) { "draft" }

      it "represents the target state with url param" do
        expect(internal_link_query_hash["state"]).to eq("draft")
      end
    end
  end

  describe "when the frontend response contains forms" do
    let(:fake_content) do
      "
        <main>
          <form action='/foo' method='get'>
            <input type='radio' name='foo' />
            <input type='text' name='bar' />
          </form>
        </main>
      "
    end

    it "updates the form and input attributes" do
      actual_content = BlockPreview::PreviewHtml.new(
        content_id: host_content_id,
        block: block_to_preview,
        base_path: host_base_path,
        locale: "en",
        state: "published",
        auth_bypass_id:,
      ).to_s

      parsed_content = Nokogiri::HTML.parse(actual_content)

      form = parsed_content.css("main form")[0]
      inputs = form.css("input")

      form_handler_path = host_content_preview_form_handler_path(
        edition_id: block_to_preview.id,
        host_content_id: host_content_id,
        locale: "en",
      )
      expected_url = "#{Plek.website_root}/foo"
      expected_action = "#{form_handler_path}&url=#{expected_url}&method=get"

      expect(form[:action]).to eq(expected_action)
      expect(form[:target]).to eq("_parent")
      expect(form[:method]).to eq("post")

      expect(inputs[0][:name]).to eq("body[foo]")
      expect(inputs[1][:name]).to eq("body[bar]")
    end
  end

  describe "when the wrapper is a div" do
    let(:fake_content) do
      "<p>test</p><div class=\"content-embed content-embed__content_block_contact\" data-content-block=\"\" data-document-type=\"content_block_contact\" data-embed-code=\"embed-code\" data-content-id=\"#{preview_content_id}\">example@example.com</div>"
    end
    let(:block_render) do
      "<div class=\"content-embed content-embed__content_block_contact\" data-content-block=\"\" data-document-type=\"content_block_contact\" data-embed-code=\"embed-code\" data-content-id=\"#{preview_content_id}\"><a class=\"govuk-link\" href=\"mailto:new@new.com\">new@new.com</a></div>"
    end

    it "returns the preview html" do
      actual_content = BlockPreview::PreviewHtml.new(
        content_id: host_content_id,
        block: block_to_preview,
        base_path: host_base_path,
        locale: "en",
        state: "published",
        auth_bypass_id:,
      ).to_s

      parsed_content = Nokogiri::HTML.parse(actual_content)

      expect(parsed_content.at_css("body.gem-c-layout-for-public--draft")).to be_present
      expect(BlockPreview::ContentDiff).to have_received(:new).with(
        anything,
        block_to_preview,
      )
      expect(content_diff_spy).to have_received(:to_s)
    end
  end

  describe "when the state is draft" do
    let(:secret) { "some_jwt_secret" }

    let!(:actual_content) do
      BlockPreview::PreviewHtml.new(
        content_id: host_content_id,
        block: block_to_preview,
        base_path: host_base_path,
        locale: "en",
        state: "draft",
        auth_bypass_id:,
      ).to_s
    end

    around do |example|
      ClimateControl.modify AUTHENTICATING_PROXY_JWT_AUTH_SECRET: secret do
        example.run
      end
    end

    it "makes a request to the draft origin" do
      expect(Net::HTTP).to have_received(:get_response) do |url|
        host_with_scheme = "#{url.scheme}://#{url.host}"
        expect(host_with_scheme).to eq(Plek.external_url_for("draft-origin"))
        expect(url.path).to eq(host_base_path)
      end
    end

    it "passes the correct arguments to the token generator" do
      expect(JWT).to have_received(:encode).with(
        {
          "sub" => auth_bypass_id,
          "content_id" => host_content_id,
          "iat" => Time.zone.now.to_i,
          "exp" => 7.days.from_now.to_i,
        },
        secret,
        "HS256",
      )
    end

    it "appends the token to the url" do
      expect(Net::HTTP).to have_received(:get_response) do |url|
        expect(url.query).to eq("token=#{token}")
      end
    end

    it "still returns the preview html" do
      parsed_content = Nokogiri::HTML.parse(actual_content)

      expect(parsed_content.at_css("body.gem-c-layout-for-public--draft")).to be_present
      expect(BlockPreview::ContentDiff).to have_received(:new).with(
        anything,
        block_to_preview,
      )
      expect(content_diff_spy).to have_received(:to_s)
    end

    it "appends the draft-origin base path to the CSS and JS references" do
      parsed_content = Nokogiri::HTML.parse(actual_content)

      expect(parsed_content.at_css("link[href='#{Plek.external_url_for('draft-origin')}/assets/application.css']")).to be_present
      expect(parsed_content.at_css("script[src='#{Plek.external_url_for('draft-origin')}/assets/application.js']")).to be_present
    end
  end

  describe "when in development mode" do
    let(:rendering_app) { "frontend" }
    let(:publishing_api_response) do
      {
        "foo" => "bar",
        "rendering_app" => rendering_app,
      }
    end

    before do
      allow(Rails.env).to receive(:development?).and_return(true)
      allow(Public::Services.publishing_api).to receive(:get_content).with(host_content_id).and_return(publishing_api_response)
    end

    it "makes a request to the rendering app as reported by the Publishing API" do
      BlockPreview::PreviewHtml.new(
        content_id: host_content_id,
        block: block_to_preview,
        base_path: host_base_path,
        locale: "en",
        state: "published",
        auth_bypass_id:,
      ).to_s

      expect(Net::HTTP).to have_received(:get_response) do |url|
        expect(url.host).to eq(Plek.external_url_for(rendering_app).sub("http://", ""))
        expect(url.path).to eq(host_base_path)
      end
    end

    describe "when the Publishing API does not report a rendering app" do
      let(:publishing_api_response) do
        {
          "foo" => "bar",
        }
      end

      it "defaults to frontend" do
        BlockPreview::PreviewHtml.new(
          content_id: host_content_id,
          block: block_to_preview,
          base_path: host_base_path,
          locale: "en",
          state: "published",
          auth_bypass_id:,
        ).to_s

        expect(Net::HTTP).to have_received(:get_response) do |url|
          expect(url.host).to eq(Plek.external_url_for("frontend").sub("http://", ""))
          expect(url.path).to eq(host_base_path)
        end
      end
    end

    describe "when the frontend app is smart answers" do
      let(:rendering_app) { "smartanswers" }

      it "makes a request to smart-answers" do
        BlockPreview::PreviewHtml.new(
          content_id: host_content_id,
          block: block_to_preview,
          base_path: host_base_path,
          locale: "en",
          state: "published",
          auth_bypass_id:,
        ).to_s

        expect(Net::HTTP).to have_received(:get_response) do |url|
          expect(url.host).to eq(Plek.external_url_for("smart-answers").sub("http://", ""))
          expect(url.path).to eq(host_base_path)
        end
      end
    end

    describe "when the state is draft" do
      it "prepends `draft` to the rendering app" do
        BlockPreview::PreviewHtml.new(
          content_id: host_content_id,
          block: block_to_preview,
          base_path: host_base_path,
          locale: "en",
          state: "draft",
          auth_bypass_id:,
        ).to_s

        expect(Net::HTTP).to have_received(:get_response) do |url|
          expect(url.host).to eq(Plek.external_url_for("draft-#{rendering_app}").sub("http://", ""))
        end
      end

      describe "when the frontend app is smart answers" do
        let(:rendering_app) { "smartanswers" }

        it "makes a request to smart-answers" do
          BlockPreview::PreviewHtml.new(
            content_id: host_content_id,
            block: block_to_preview,
            base_path: host_base_path,
            locale: "en",
            state: "draft",
            auth_bypass_id:,
          ).to_s

          expect(Net::HTTP).to have_received(:get_response) do |url|
            expect(url.host).to eq(Plek.external_url_for("smart-answers").sub("http://", ""))
            expect(url.path).to eq(host_base_path)
          end
        end
      end

      describe "when the Publishing API does not report a rendering app" do
        let(:publishing_api_response) do
          {
            "foo" => "bar",
          }
        end

        it "defaults to draft-frontend" do
          BlockPreview::PreviewHtml.new(
            content_id: host_content_id,
            block: block_to_preview,
            base_path: host_base_path,
            locale: "en",
            state: "draft",
            auth_bypass_id:,
          ).to_s

          expect(Net::HTTP).to have_received(:get_response) do |url|
            expect(url.host).to eq(Plek.external_url_for("draft-frontend").sub("http://", ""))
            expect(url.path).to eq(host_base_path)
          end
        end
      end
    end
  end
end
