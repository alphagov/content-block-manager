module Edition::Workflow
  extend ActiveSupport::Concern
  include DateValidation

  class ReviewOutcomeMissingError < RuntimeError; end
  class WorkflowCompletionError < RuntimeError; end

  included do
    include ActiveRecord::Transitions

    class << self
      def active_states
        available_states - inactive_states
      end

      def inactive_states
        %i[superseded deleted]
      end

      def in_progress_states
        available_states - finalised_states
      end

      def finalised_states
        %i[published superseded deleted]
      end
    end

    date_attributes :scheduled_publication

    validates_with ScheduledPublicationValidator, if: -> { validation_context == :scheduling || state == "scheduled" }

    state_machine auto_scopes: true do
      state :draft
      state :draft_complete
      state :published
      state :scheduled
      state :superseded
      state :awaiting_review
      state :awaiting_factcheck
      state :deleted

      event :publish do
        transitions from: %i[draft draft_complete awaiting_review awaiting_factcheck scheduled], to: :published
      end
      event :schedule do
        transitions from: %i[draft draft_complete awaiting_factcheck], to: :scheduled
      end
      event :supersede do
        transitions from: %i[scheduled], to: :superseded
      end
      event :complete_draft do
        transitions from: %i[draft], to: :draft_complete, guard: [:workflow_completed?]
      end
      event :ready_for_review do
        transitions from: %i[draft draft_complete], to: :awaiting_review
      end
      event :ready_for_factcheck do
        transitions from: %i[awaiting_review], to: :awaiting_factcheck, guard: [:has_review_outcome_recorded?]
      end
      event :delete, success: lambda { |edition|
        DeleteEditionService.new.call(edition)
      } do
        transitions from: %i[draft draft_complete awaiting_review awaiting_factcheck scheduled], to: :deleted
      end
    end

    def has_review_outcome_recorded?
      return true if review_outcome.present?

      error_message = "Edition #{id} does not have a 2i Review outcome recorded and so " \
        "can't transition into the 'awaiting_factcheck' state"
      raise ReviewOutcomeMissingError, error_message
    end

    def workflow_completed?
      return true if completed?

      error_message = "Edition #{id}'s workflow has not been completed"
      raise WorkflowCompletionError, error_message
    end

    def in_progress?
      state.to_sym.in?(self.class.in_progress_states)
    end
  end
end
