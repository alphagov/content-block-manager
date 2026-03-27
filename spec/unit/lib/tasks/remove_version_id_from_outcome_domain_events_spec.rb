RSpec.describe Rake::Task["remove_version_id_from_outcome_domain_events"] do
  after do
    described_class.reenable
  end

  outcome_domain_event_names = %w[edition.review.performed
                                  edition.review.skipped
                                  edition.fact_check.performed
                                  edition.fact_check.skipped]

  describe "when a domain event relates to an outcome" do
    let(:document) { create(:document, :pension) }

    outcome_domain_event_names.each do |domain_event_name|
      context "for the #{domain_event_name} domain event" do
        let(:version) { create(:content_block_version) }
        let!(:domain_event) do
          create(
            :domain_event,
            name: domain_event_name,
            document:,
            version_id: version.id,
          )
        end

        before do
          described_class.invoke
        end

        it "should set the version_id to nil" do
          domain_event.reload
          expect(domain_event.version_id).to be_nil
        end
      end
    end
  end

  describe "when a domain event does not relate to an outcome" do
    let(:document) { create(:document, :pension) }

    (DomainEvent::EVENT_NAMES - outcome_domain_event_names).each do |domain_event_name|
      context "for the #{domain_event_name} domain event" do
        let(:version) { create(:content_block_version) }
        let!(:domain_event) do
          create(
            :domain_event,
            name: domain_event_name,
            document:,
            version_id: version.id,
          )
        end

        before do
          described_class.invoke
        end

        it "should keep the version_id intact" do
          domain_event.reload
          expect(domain_event.version_id).not_to be_nil
          expect(domain_event.version_id).to be(version.id)
        end
      end
    end
  end
end
