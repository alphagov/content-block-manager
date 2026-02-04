RSpec.describe "layouts/design_system", type: :view do
  before do
    without_partial_double_verification do
      allow(view).to receive(:user_signed_in?).and_return(true)
      allow(view).to receive(:current_user).and_return(build(:user))
      allow(view).to receive(:product_name).and_return("Content Block Manager")
      allow(view).to receive(:navigation_items).and_return([])
    end
  end

  describe "modules" do
    context "when ga4_form_tracking? is set" do
      before do
        allow(view).to receive(:ga4_form_tracking?).and_return(true)
      end

      it "sets the ga4_form_setup module" do
        render

        expect(rendered).to have_css('[data-module="ga4-form-setup"]')
      end
    end

    context "when ga4_form_tracking? is not set" do
      before do
        allow(view).to receive(:ga4_form_tracking?).and_return(false)
      end

      it "sets the ga4_form_setup module" do
        render

        expect(rendered).to_not have_css('[data-module="ga4-form-setup"]')
      end
    end
  end
end
