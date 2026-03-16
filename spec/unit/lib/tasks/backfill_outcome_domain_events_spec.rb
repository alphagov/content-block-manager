RSpec.describe Rake::Task["backfill_outcome_domain_events"] do
  after do
    described_class.reenable
  end

  it "backfills domain events only for outcomes missing one" do
    performed_outcome = create(:review_outcome, skipped: false, performer: "Jane Doe")
    performed_outcome.update_column(:domain_event_id, nil)

    skipped_outcome = create(:fact_check_outcome, skipped: true, performer: "Unused")
    skipped_outcome.update_column(:domain_event_id, nil)

    outcome_with_domain_event = create(:fact_check_outcome, skipped: true)
    existing_domain_event_id = outcome_with_domain_event.domain_event_id

    expect {
      described_class.invoke
    }.to change(DomainEvent, :count).by(2)

    aggregate_failures do
      expect(performed_outcome.reload.domain_event).to be_present
      expect(performed_outcome.domain_event.name).to eq("edition.review.performed")
      expect(performed_outcome.domain_event.metadata).to eq({ "performer" => "Jane Doe" })

      expect(skipped_outcome.reload.domain_event).to be_present
      expect(skipped_outcome.domain_event.name).to eq("edition.fact_check.skipped")
      expect(skipped_outcome.domain_event.metadata).to eq({})

      expect(outcome_with_domain_event.reload.domain_event_id).to eq(existing_domain_event_id)
    end
  end
end
