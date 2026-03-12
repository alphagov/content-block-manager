RSpec.describe DetailsValidator do
  describe "contact schema" do
    let(:document) { build(:document, :contact) }

    let(:email_address) { "test@example.com" }

    let(:email_addresses) do
      {
        "email-1": {
          title: "Email",
          email_address:,
        },
      }
    end

    let(:label) { "Contact us" }
    let(:url) { "https://www.example.com/contact" }

    let(:contact_links) do
      {
        "link-1": {
          title: "Contact link",
          label:,
          url:,
        },
      }
    end

    let(:telephone_number) { "01234 567890" }
    let(:telephone_label) { "Telephone" }

    let(:telephone_numbers) do
      [
        {
          label: telephone_label,
          telephone_number:,
        },
      ]
    end

    let(:telephones) do
      {
        "telephone-1": {
          title: "Telephone",
          telephone_numbers:,
        },
      }
    end

    let(:details) do
      {
        description: "Test contact description",
        email_addresses:,
        contact_links:,
        telephones:,
      }
    end

    subject { build(:edition, :contact, details:, document:) }

    before do
      subject.valid?
    end

    let(:errors) { subject.errors }

    context "when the details are valid" do
      it { is_expected.to be_valid }
    end

    context "when description is omitted" do
      let(:details) { { email_addresses: } }

      it { is_expected.to be_valid }
    end

    describe "email_addresses" do
      context "when email_address is missing" do
        let(:email_addresses) do
          {
            "email-1": {
              title: "Email",
            },
          }
        end

        it { is_expected.not_to be_valid }

        it "adds an error to the email_address field" do
          expect(errors[:details_email_addresses_email_address]).to include("Email address cannot be blank")
        end
      end

      context "when email_address is not a valid email" do
        let(:email_address) { "not-an-email" }

        it { is_expected.not_to be_valid }

        it "adds an error to the email_address field" do
          expect(errors[:details_email_addresses_email_address]).to include("Invalid Email address")
        end
      end

      context "when email_address is valid" do
        let(:email_address) { "valid@example.gov.uk" }

        it { is_expected.to be_valid }
      end
    end

    describe "contact_links" do
      context "when label is missing" do
        let(:contact_links) do
          {
            "link-1": {
              url:,
            },
          }
        end

        it { is_expected.not_to be_valid }

        it "adds an error to the label field" do
          expect(errors[:details_contact_links_label]).to include("Label cannot be blank")
        end
      end

      context "when url is missing" do
        let(:contact_links) do
          {
            "link-1": {
              label:,
            },
          }
        end

        it { is_expected.not_to be_valid }

        it "adds an error to the url field" do
          expect(errors[:details_contact_links_url]).to include("URL cannot be blank")
        end
      end

      context "when url is not a valid URL" do
        let(:url) { "not a url" }

        it { is_expected.not_to be_valid }

        it "adds an error to the url field" do
          expect(errors[:details_contact_links_url]).to include("URL is invalid")
        end
      end
    end

    describe "telephones" do
      context "when telephone_numbers is missing" do
        let(:telephones) do
          {
            "telephone-1": {
              title: "Telephone",
            },
          }
        end

        it { is_expected.not_to be_valid }

        it "adds an error to the telephone_numbers field" do
          expect(errors[:details_telephones_telephone_numbers]).to include("Telephone numbers cannot be blank")
        end
      end

      context "when a telephone number entry is missing a label" do
        let(:telephone_numbers) do
          [{ telephone_number: "01234 567890" }]
        end

        it { is_expected.not_to be_valid }

        it "adds an error to the label field" do
          expect(errors[:details_telephones_telephone_numbers_0_label]).to include("Label cannot be blank")
        end
      end

      context "when a telephone number entry is missing a telephone_number" do
        let(:telephone_numbers) do
          [{ label: "Telephone" }]
        end

        it { is_expected.not_to be_valid }

        it "adds an error to the telephone_number field" do
          expect(errors[:details_telephones_telephone_numbers_0_telephone_number]).to include("Telephone number cannot be blank")
        end
      end

      describe "call_charges" do
        context "when show_call_charges_info_url is true" do
          let(:telephones) do
            {
              "telephone-1": {
                telephone_numbers:,
                call_charges: {
                  show_call_charges_info_url: true,
                  label: "Find out about call charges",
                  call_charges_info_url: "https://gov.uk/call-charges",
                },
              },
            }
          end

          it { is_expected.to be_valid }
        end

        context "when show_call_charges_info_url is true but label is missing" do
          let(:telephones) do
            {
              "telephone-1": {
                telephone_numbers:,
                call_charges: {
                  show_call_charges_info_url: true,
                  call_charges_info_url: "https://gov.uk/call-charges",
                },
              },
            }
          end

          it { is_expected.not_to be_valid }
        end

        context "when show_call_charges_info_url is true but call_charges_info_url is missing" do
          let(:telephones) do
            {
              "telephone-1": {
                telephone_numbers:,
                call_charges: {
                  show_call_charges_info_url: true,
                  label: "Find out about call charges",
                },
              },
            }
          end

          it { is_expected.not_to be_valid }
        end

        context "when show_call_charges_info_url is false, label and url are not required" do
          let(:telephones) do
            {
              "telephone-1": {
                telephone_numbers:,
                call_charges: {
                  show_call_charges_info_url: false,
                },
              },
            }
          end

          it { is_expected.to be_valid }
        end
      end

      describe "opening_hours" do
        context "when show_opening_hours is true with opening_hours provided" do
          let(:telephones) do
            {
              "telephone-1": {
                telephone_numbers:,
                opening_hours: {
                  show_opening_hours: true,
                  opening_hours: "Monday to Friday, 9am to 5pm",
                },
              },
            }
          end

          it { is_expected.to be_valid }
        end

        context "when show_opening_hours is true but opening_hours is missing" do
          let(:telephones) do
            {
              "telephone-1": {
                telephone_numbers:,
                opening_hours: {
                  show_opening_hours: true,
                },
              },
            }
          end

          it { is_expected.not_to be_valid }
        end

        context "when show_opening_hours is false, opening_hours is not required" do
          let(:telephones) do
            {
              "telephone-1": {
                telephone_numbers:,
                opening_hours: {
                  show_opening_hours: false,
                },
              },
            }
          end

          it { is_expected.to be_valid }
        end
      end

      describe "video_relay_service" do
        context "when show is true with all required fields provided" do
          let(:telephones) do
            {
              "telephone-1": {
                telephone_numbers:,
                video_relay_service: {
                  show: true,
                  label: "Text relay: dial 18001 then:",
                  telephone_number: "0800 1234 1234",
                  source: "Provider: [Relay UK](https://www.relayuk.bt.com)",
                },
              },
            }
          end

          it { is_expected.to be_valid }
        end

        context "when show is true but label is missing" do
          let(:telephones) do
            {
              "telephone-1": {
                telephone_numbers:,
                video_relay_service: {
                  show: true,
                  telephone_number: "0800 1234 1234",
                  source: "Provider: [Relay UK](https://www.relayuk.bt.com)",
                },
              },
            }
          end

          it { is_expected.not_to be_valid }
        end

        context "when show is true but telephone_number is missing" do
          let(:telephones) do
            {
              "telephone-1": {
                telephone_numbers:,
                video_relay_service: {
                  show: true,
                  label: "Text relay: dial 18001 then:",
                  source: "Provider: [Relay UK](https://www.relayuk.bt.com)",
                },
              },
            }
          end

          it { is_expected.not_to be_valid }
        end

        context "when show is true but source is missing" do
          let(:telephones) do
            {
              "telephone-1": {
                telephone_numbers:,
                video_relay_service: {
                  show: true,
                  label: "Text relay: dial 18001 then:",
                  telephone_number: "0800 1234 1234",
                },
              },
            }
          end

          it { is_expected.not_to be_valid }
        end

        context "when show is false, required fields are not needed" do
          let(:telephones) do
            {
              "telephone-1": {
                telephone_numbers:,
                video_relay_service: {
                  show: false,
                },
              },
            }
          end

          it { is_expected.to be_valid }
        end
      end
    end

    describe "order" do
      context "when order contains valid entries" do
        let(:details) do
          {
            telephones:,
            order: %w[telephones.telephone-1 addresses contact_links email_addresses],
          }
        end

        it { is_expected.to be_valid }
      end

      context "when order contains an invalid entry" do
        let(:details) do
          {
            telephones:,
            order: %w[INVALID_SECTION],
          }
        end

        it { is_expected.not_to be_valid }
      end
    end
  end
end
