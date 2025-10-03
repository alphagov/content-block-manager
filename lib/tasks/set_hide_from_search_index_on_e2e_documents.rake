desc "Data migration to set testing_artefact to true for all documents created by e2e users"
task set_testing_artefact_on_e2e_documents: :environment do
  e2e_user_ids = User.where(email: ENV["E2E_USER_EMAILS"].split(",")).pluck(:id)
  document_ids = Version
                .where(whodunnit: e2e_user_ids, item_type: "Edition")
                .map { |version| version.item.document }
  Document.where(id: document_ids).update_all(testing_artefact: true)
end
