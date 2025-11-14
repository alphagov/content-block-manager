module Edition::Workflow
  extend ActiveSupport::Concern
  include DateValidation

  STATES = %w[draft published scheduled superseded awaiting_2i].freeze

  class_methods do
    def valid_state?(state)
      STATES.include?(state)
    end
  end

  included do
    include ActiveRecord::Transitions

    date_attributes :scheduled_publication

    validates_with ScheduledPublicationValidator, if: -> { validation_context == :scheduling || state == "scheduled" }

    state_machine auto_scopes: true do
      STATES.each { |state_name| state state_name.to_sym }

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
