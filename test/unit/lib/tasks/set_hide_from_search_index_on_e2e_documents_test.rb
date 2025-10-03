require "test_helper"
require "rake"

class SetHideFromSearchIndexOnE2EDocumentsTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:task) { Rake::Task["set_testing_artefact_on_e2e_documents"] }

  let(:e2e_user_emails) { %w[e2euser1@example.com e2euser2@example.com] }
  let(:e2e_users) do
    e2e_user_emails.map do |email|
      create(:user, email: email)
    end
  end
  let(:user) { create(:user) }

  teardown do
    Rake::Task["set_testing_artefact_on_e2e_documents"].reenable
  end

  it "sets the testing_artefact flag on all documents created or updated by e2e users" do
    e2e_documents = e2e_users.map { |e2e_user| Array.new(2) { create_document(whodunnit: e2e_user.id) } }.flatten
    non_e2e_documents = Array.new(3) { create_document(whodunnit: user.id) }

    ClimateControl.modify E2E_USER_EMAILS: e2e_user_emails.join(",") do
      task.invoke
    end

    e2e_documents.each do |document|
      assert document.reload.testing_artefact
    end

    non_e2e_documents.each do |document|
      assert_not document.reload.testing_artefact
    end
  end

  def create_document(whodunnit:)
    document = create(:document)
    editions = create_list(:edition, 2, document: document)
    editions.each { |edition| create(:content_block_version, item: edition, whodunnit:) }
    document
  end
end
