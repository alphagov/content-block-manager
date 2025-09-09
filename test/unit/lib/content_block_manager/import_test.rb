require "test_helper"

class ContentBlockManager::ImportTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:users) do
    [
      {
        "id": "1",
        "name": "User",
        "uid": SecureRandom.uuid,
        "email": "example@digital.cabinet-office.gov.uk",
        "disabled": false,
        "remotely_signed_out": false,
        "permissions": %w[signin],
        "created_at": Time.zone.now,
        "updated_at": Time.zone.now,
        "organisation_slug": "government-digital-service",
        "organisation_content_id": nil,
      },
    ]
  end

  let(:content_block_documents) do
    [
      {
        "id": "1",
        "content_id": SecureRandom.uuid,
        "sluggable_string": "Basic State Pension",
        "block_type": "pension",
        "latest_edition_id": 1,
        "live_edition_id": 1,
        "content_id_alias": "basic-state-pension",
        "deleted_at": nil,
        "created_at": "2025-03-06 10:44:42",
        "updated_at": "2025-04-06 23:01:00",
      },
    ]
  end

  let(:details) do
    {
      "rates" => {
        "full-basic-state-pension-amount" => {
          "title" => "Full basic State Pension amount",
          "amount" => "£169.50",
          "frequency" => "a week",
        },
      },
      "description" => "The full basic State Pension amount.",
    }
  end

  let(:content_block_editions) do
    [
      {
        "id": "1",
        "creator_id": 1,
        "details": details,
        "document_id": 1,
        "state": "published",
        "scheduled_publication": nil,
        "instructions_to_publishers": "Blah",
        "title": "Basic State Pension",
        "internal_change_note": nil,
        "change_note": nil,
        "major_change": nil,
        "created_at": "2025-03-06 10:44:42",
        "updated_at": "2025-03-06 10:47:24",
        "lead_organisation_id": "b548a09f-8b35-4104-89f4-f1a40bf3136d",
      },
    ]
  end

  let(:content_block_versions) do
    [
      {
        "id": "1",
        "item_type": "ContentBlockManager::ContentBlock::Edition",
        "item_id": 1,
        "event": 0,
        "whodunnit": "1",
        "state": nil,
        "field_diffs": nil,
        "updated_embedded_object_type": nil,
        "updated_embedded_object_title": nil,
        "created_at": "2025-03-06 10:44:42",
        "updated_at": "2025-03-06 10:44:42",
      },
    ]
  end

  before do
    create_list(:user, 5)
    create_list(:content_block_document, 6, :pension)

    schema = stub(:schema, body: {})
    ContentBlockManager::ContentBlock::Schema.stubs(:find_by_block_type).with(anything).returns(schema)
  end

  it "imports the data correctly" do
    File.expects(:read).with("/tmp/users.json").returns(users.to_json)
    File.expects(:read).with("/tmp/content_block_documents.json").returns(content_block_documents.to_json)
    File.expects(:read).with("/tmp/content_block_editions.json").returns(content_block_editions.to_json)
    File.expects(:read).with("/tmp/content_block_versions.json").returns(content_block_versions.to_json)

    ContentBlockManager::Import.new.perform!

    assert_equal User.all.count, 1
    assert_equal ContentBlockManager::ContentBlock::Document.all.count, 1
    assert_equal ContentBlockManager::ContentBlock::Edition.all.count, 1
    assert_equal ContentBlockManager::ContentBlock::Version.all.count, 1

    user = User.all.last
    document = ContentBlockManager::ContentBlock::Document.last
    edition = ContentBlockManager::ContentBlock::Edition.last
    version = ContentBlockManager::ContentBlock::Version.last

    assert_equal user.name, "User"
    assert_equal user.email, "example@digital.cabinet-office.gov.uk"

    assert_equal document.title, "Basic State Pension"
    assert_equal document.latest_edition, edition

    assert_equal document.versions, [version]

    assert_equal edition.details, details
  end

  it "rolls back if an error is raised" do
    File.expects(:read).with("/tmp/users.json").returns(users.to_json)
    File.expects(:read).with("/tmp/content_block_documents.json").raises(StandardError.new("Something went wrong"))

    assert_raises(StandardError) do
      ContentBlockManager::Import.new.perform!
    end

    assert_equal User.all.count, 5
    assert_equal ContentBlockManager::ContentBlock::Document.all.count, 6
  end

  it "rolls back on a validation error" do
    File.stubs(:read).with("/tmp/users.json").returns(users.to_json)
    File.stubs(:read).with("/tmp/content_block_documents.json").returns(content_block_documents.to_json)
    File.stubs(:read).with("/tmp/content_block_editions.json").returns(content_block_editions.to_json)
    File.stubs(:read).with("/tmp/content_block_versions.json").returns(content_block_versions.to_json)

    ContentBlockManager::ContentBlock::Edition.expects(:create!).with(anything).raises(
      ActiveModel::ValidationError.new(build(:content_block_edition)),
    )

    assert_raises(ActiveModel::ValidationError) do
      ContentBlockManager::Import.new.perform!
    end

    assert_equal User.all.count, 5
    assert_equal ContentBlockManager::ContentBlock::Document.all.count, 6
  end
end
