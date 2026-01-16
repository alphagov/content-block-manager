RSpec.describe FactCheck::BlocksController, type: :request do
  include FactCheck::Engine.routes.url_helpers

  describe "#show" do
    let(:block) { build(:content_block) }
    let(:content_id) { "some-content-block" }
    let(:user) { create(:user) }
    let(:cookie_jar) { ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash) }
    let(:document) { create(:document) }
    let(:current_edition) { create(:edition, document:) }
    let(:published_edition) { create(:edition, document:) }
    let(:subschemas) do
      [
        double(:subschema, id: "email_addresses", block_type: "email_addresses", group_order: 1),
        double(:subschema, id: "telephones", block_type: "telephones", group_order: 2),
        double(:subschema, id: "addresses", block_type: "addresses", group_order: 3),
        double(:subschema, id: "contact_links", block_type: "contact_links", group_order: 4),
      ]
    end
    let(:schema) { double(:schema, subschemas: subschemas, embeddable_as_block?: true, body: {}) }

    before do
      ENV["JWT_AUTH_SECRET"] = "secret"
      allow(ContentBlock).to receive(:from_content_id_alias).with(content_id).and_return(block)
      allow(Document).to receive(:find).and_return(document)
      allow(document).to receive(:schema).and_return(schema)
      allow(document).to receive(:most_recent_edition).and_return(current_edition)
      allow(document).to receive(:latest_published_edition).and_return(published_edition)
      allow(Schema).to receive(:find_by_block_type).and_return(schema)
    end

    context "when the user is authenticated" do
      before do
        logout
        login_as(user)
      end

      it "returns success" do
        get block_path(content_id)

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
      end
    end

    context "when the user is not authenticated" do
      let(:valid_token) do
        JWT.encode(
          { sub: block.auth_bypass_id },
          ENV["JWT_AUTH_SECRET"],
          "HS256",
        )
      end

      before do
        logout
      end

      around do |test|
        # Disable GDS SSO mocking for these tests
        ClimateControl.modify("GDS_SSO_MOCK_INVALID" => "1") do
          test.call
        end
      end

      describe "with valid JWT token" do
        before do
          get block_path(content_id, token: valid_token)
        end

        it "allows access when token subject matches block auth_bypass_id" do
          expect(response).to have_http_status(:success)
          expect(response).to render_template(:show)
        end

        it "sets the jwt token as a cookie" do
          expect(cookie_jar.signed[:token]).to eq(valid_token)
        end

        it "allows subsequent access without the token param once the cookie is set" do
          get block_path(content_id)

          expect(response).to have_http_status(:success)
          expect(response).to render_template(:show)
        end
      end

      describe "with invalid JWT token" do
        before do
          get block_path(content_id, token: "invalid.jwt.token")
        end

        it "requires GDS SSO authentication" do
          expect(response).to_not render_template(:show)
          expect(response).to redirect_to("/auth/gds")
        end

        it "does not set the jwt token as a cookie" do
          expect(cookie_jar.signed[:token]).to be_nil
        end
      end

      describe "with mismatched JWT subject" do
        let(:mismatched_token) do
          JWT.encode(
            { sub: "different-auth-bypass-id" },
            ENV["JWT_AUTH_SECRET"],
            "HS256",
          )
        end

        before do
          get block_path(content_id, token: mismatched_token)
        end

        it "requires GDS SSO authentication" do
          expect(response).to_not render_template(:show)
          expect(response).to redirect_to("/auth/gds")
        end

        it "does not set the jwt token as a cookie" do
          expect(cookie_jar.signed[:token]).to be_nil
        end
      end
    end
  end
end
