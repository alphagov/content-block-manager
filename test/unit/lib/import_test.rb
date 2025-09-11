require "test_helper"

class ImportTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:users) do
    [
      {
        "id": "10",
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

  let(:documents) do
    [
      {
        "id": "10",
        "content_id": SecureRandom.uuid,
        "sluggable_string": "Basic State Pension",
        "block_type": "pension",
        "latest_edition_id": 10,
        "live_edition_id": 10,
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

  let(:editions) do
    [
      {
        "id": "10",
        "creator_id": 10,
        "details": details,
        "document_id": 10,
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

  let(:versions) do
    [
      {
        "id": "10",
        "item_type": "Edition",
        "item_id": 10,
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
    create_list(:document, 6, :pension)

    schema = stub(:schema, body: {})
    Schema.stubs(:find_by_block_type).with(anything).returns(schema)
  end

  it "imports the data correctly" do
    File.expects(:read).with("/tmp/users.json").returns(users.to_json)
    File.expects(:read).with("/tmp/documents.json").returns(documents.to_json)
    File.expects(:read).with("/tmp/editions.json").returns(editions.to_json)
    File.expects(:read).with("/tmp/versions.json").returns(versions.to_json)

    Import.new.perform!

    assert_equal User.all.count, 1
    assert_equal Document.all.count, 1
    assert_equal Edition.all.count, 1
    assert_equal Version.all.count, 1

    user = User.all.last
    document = Document.last
    edition = Edition.last
    version = Version.last

    assert_equal user.name, "User"
    assert_equal user.email, "example@digital.cabinet-office.gov.uk"

    assert_equal document.title, "Basic State Pension"
    assert_equal document.latest_edition, edition

    assert_equal document.versions, [version]

    assert_equal edition.details, details
  end

  it "rolls back if an error is raised" do
    File.expects(:read).with("/tmp/users.json").returns(users.to_json)
    File.expects(:read).with("/tmp/documents.json").raises(StandardError.new("Something went wrong"))

    assert_raises(StandardError) do
      Import.new.perform!
    end

    assert_equal User.all.count, 5
    assert_equal Document.all.count, 6
  end

  it "rolls back on a validation error" do
    File.stubs(:read).with("/tmp/users.json").returns(users.to_json)
    File.stubs(:read).with("/tmp/documents.json").returns(documents.to_json)
    File.stubs(:read).with("/tmp/editions.json").returns(editions.to_json)
    File.stubs(:read).with("/tmp/versions.json").returns(versions.to_json)

    Edition.expects(:create!).with(anything).raises(
      ActiveModel::ValidationError.new(build(:edition)),
    )

    assert_raises(ActiveModel::ValidationError) do
      Import.new.perform!
    end

    assert_equal User.all.count, 5
    assert_equal Document.all.count, 6
  end

  it "resets the primary key sequence" do
    File.expects(:read).with("/tmp/users.json").returns(users.to_json)
    File.expects(:read).with("/tmp/documents.json").returns(documents.to_json)
    File.expects(:read).with("/tmp/editions.json").returns(editions.to_json)
    File.expects(:read).with("/tmp/versions.json").returns(versions.to_json)

    Import.new.perform!

    new_user = create(:user)
    new_document = create(:document)
    new_edition = create(:edition, document: new_document)

    assert_equal new_user.id, 11
    assert_equal new_document.id, 11
    assert_equal new_edition.id, 11
    assert_equal new_edition.versions[0].id, 11
  end
end
