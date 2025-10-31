module Edition::Workflow
  extend ActiveSupport::Concern
  include DateValidation

  module ClassMethods
    def valid_state?(state)
      %w[draft published scheduled superseded].include?(state)
    end
  end

  included do
    include ActiveRecord::Transitions

    date_attributes :scheduled_publication

    validates_with ScheduledPublicationValidator, if: -> { validation_context == :scheduling || state == "scheduled" }

    state_machine auto_scopes: true do
      state :draft
      state :published
      state :scheduled
      state :superseded
      state :awaiting_2i

      event :publish do
        transitions from: %i[draft awaiting_2i scheduled], to: :published
      end
      event :schedule do
        transitions from: %i[draft], to: :scheduled
      end
      event :supersede do
        transitions from: %i[scheduled], to: :superseded
      end
      event :ready_for_2i do
        transitions from: %i[draft], to: :awaiting_2i
      end
    end
  end
end
