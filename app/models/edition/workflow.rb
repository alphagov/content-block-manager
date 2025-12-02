module Edition::Workflow
  extend ActiveSupport::Concern
  include DateValidation

  class_methods do
    def valid_state?(state)
      edition.available_states.include?(state)
    end
  end

  included do
    include ActiveRecord::Transitions

    class << self
      def active_states
        Edition.available_states - inactive_states
      end

      def inactive_states
        %i[superseded deleted]
      end
    end

    date_attributes :scheduled_publication

    validates_with ScheduledPublicationValidator, if: -> { validation_context == :scheduling || state == "scheduled" }

    state_machine auto_scopes: true do
      state :draft
      state :published
      state :scheduled
      state :superseded
      state :awaiting_review
      state :deleted

      event :publish do
        transitions from: %i[draft awaiting_review scheduled], to: :published
      end
      event :schedule do
        transitions from: %i[draft], to: :scheduled
      end
      event :supersede do
        transitions from: %i[scheduled], to: :superseded
      end
      event :ready_for_2i do
        transitions from: %i[draft], to: :awaiting_review
      end
      event :delete, success: lambda { |edition|
        DeleteEditionService.new.call(edition)
      } do
        transitions from: %i[draft awaiting_review scheduled], to: :deleted
      end
    end
  end
end
