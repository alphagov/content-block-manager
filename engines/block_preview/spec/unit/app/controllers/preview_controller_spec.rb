RSpec.describe BlockPreview::PreviewController, type: :controller do
  routes { BlockPreview::Engine.routes }

  describe "GET #show" do
    let(:edition_id) { "123" }
    let(:host_content_id) { "content-id-abc" }
    let(:base_path) { "/government/base-path" }
    let(:locale) { "en" }

    let(:mock_block) { instance_double("ContentBlock") }
    let(:mock_preview_content) { instance_double(BlockPreview::PreviewContent) }

    before do
      allow(ContentBlock).to receive(:from_edition_id).and_return(mock_block)
      allow(BlockPreview::PreviewContent).to receive(:new).and_return(mock_preview_content)

      get :show, params: {
        edition_id: edition_id,
        host_content_id: host_content_id,
        base_path: base_path,
        locale: locale,
      }
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "finds the content block using the edition_id param" do
      expect(ContentBlock).to have_received(:from_edition_id).with(edition_id)
    end

    it "initializes the preview content service with the correct params" do
      expect(BlockPreview::PreviewContent).to have_received(:new).with(
        content_id: host_content_id,
        block: mock_block,
        base_path: base_path,
        locale: locale,
      )
    end

    it "assigns the @block instance variable" do
      expect(assigns(:block)).to eq(mock_block)
    end

    it "assigns the @preview_content instance variable" do
      expect(assigns(:preview_content)).to eq(mock_preview_content)
    end
  end

  describe "POST #form_handler" do
    let(:edition_id) { "123" }
    let(:host_content_id) { "content-id-abc" }
    let(:url) { "https://example.gov.uk/form" }
    let(:http_method) { "post" }
    let(:body_params) { { "field_name" => "field_value" } }
    let(:locale) { "en" }

    let(:mock_block) { instance_double("ContentBlock", id: 456) }
    let(:mock_submission) { instance_double(BlockPreview::FormSubmission) }
    let(:redirect_path_result) { "/thank-you" }

    let(:make_request!) do
      post :form_handler, params: {
        edition_id: edition_id,
        host_content_id: host_content_id,
        url: url,
        method: http_method,
        body: body_params,
        locale: locale,
      }
    end

    before do
      allow(ContentBlock).to receive(:from_edition_id).with(edition_id).and_return(mock_block)
      allow(BlockPreview::FormSubmission).to receive(:new).and_return(mock_submission)
      allow(mock_submission).to receive(:redirect_path).and_return(redirect_path_result)
    end

    context "with valid parameters and successful submission" do
      before do
        make_request!
      end

      it "initializes FormSubmission with correct arguments" do
        expect(BlockPreview::FormSubmission).to have_received(:new).with(
          url: url,
          body: body_params,
          method: http_method,
        )
      end

      it "redirects to the preview page with the new base path" do
        expected_path = host_content_preview_path(
          edition_id: mock_block.id,
          host_content_id: host_content_id,
          locale: locale,
          base_path: redirect_path_result,
        )

        expect(response).to redirect_to(expected_path)
      end
    end

    context "when the form submission fails" do
      before do
        allow(mock_submission).to receive(:redirect_path).and_raise(error)
        make_request!
      end

      context "with UnexpectedResponseError" do
        let(:error) { BlockPreview::FormSubmission::UnexpectedResponseError }

        it "returns 400 Bad Request" do
          expect(response).to have_http_status(:bad_request)
        end
      end

      context "with UnexpectedUrlError" do
        let(:error) { BlockPreview::FormSubmission::UnexpectedUrlError }

        it "returns 400 Bad Request" do
          expect(response).to have_http_status(:bad_request)
        end
      end
    end
  end
end
