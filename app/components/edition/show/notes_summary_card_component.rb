class Edition::Show::NotesSummaryCardComponent < ViewComponent::Base
  def initialize(edition:)
    @edition = edition
  end

private

  attr_reader :edition

  def title
    "Notes"
  end

  def rows
    edition.major_change ? [internal_change_note_item, major_change_item, external_change_note_item] : [internal_change_note_item, major_change_item]
  end

  def internal_change_note_item
    {
      key: "Internal note",
      value: edition.internal_change_note.presence || "None",
      actions: [
        {
          label: "Edit",
          href: helpers.workflow_path(id: edition.id, step: :internal_note),
        },
      ],
    }
  end

  def major_change_item
    {
      key: "Do users have to know the content has changed?",
      value: edition.major_change ? "Yes" : "No",
      actions: [
        {
          href: helpers.workflow_path(id: edition.id, step: :change_note),
          label: "Edit",
        },
      ],
    }
  end

  def external_change_note_item
    {
      key: "Public change note",
      value: edition.change_note,
      actions:
        [
          {
            href: helpers.workflow_path(id: edition.id, step: :change_note),
            label: "Edit",
          },
        ],
    }
  end
end
