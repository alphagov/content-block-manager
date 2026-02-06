RSpec.shared_examples "allows authentication with a JWT" do
  let(:user) { create(:user) }
  let(:cookie_jar) { ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash) }

  def path_with_token(path, token)
    modified_path = Addressable::URI.parse(path)
    query_values = modified_path.query_values || {}
    query_values.merge!({ token: })
    modified_path.query_values = query_values
    modified_path.to_s
  end

  before do
    ENV["JWT_AUTH_SECRET"] = "secret"
  end

  context "when the user is authenticated" do
    before do
      logout
      login_as(user)
    end

    it "returns success" do
      get path

      expect(response).to have_http_status(:success)
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
        get path_with_token(path, valid_token)
      end

      it "allows access when token subject matches block auth_bypass_id" do
        expect(response).to have_http_status(:success)
      end

      it "sets the jwt token as a cookie" do
        expect(cookie_jar.signed[:token]).to eq(valid_token)
      end

      it "allows subsequent access without the token param once the cookie is set" do
        get path

        expect(response).to have_http_status(:success)
      end
    end

    describe "with invalid JWT token" do
      before do
        get path_with_token(path, "invalid.jwt.token")
      end

      it "requires GDS SSO authentication" do
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
        get path_with_token(path, mismatched_token)
      end

      it "requires GDS SSO authentication" do
        expect(response).to redirect_to("/auth/gds")
      end

      it "does not set the jwt token as a cookie" do
        expect(cookie_jar.signed[:token]).to be_nil
      end
    end
  end
end
