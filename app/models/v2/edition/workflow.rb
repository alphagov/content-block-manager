module V2::Edition::Workflow
  extend ActiveSupport::Concern

  included do
    include ActiveRecord::Transitions

    class << self
      def active_states
        available_states - inactive_states
      end

      def inactive_states
        []
      end

      def in_progress_states
        available_states - finalised_states
      end

      def finalised_states
        %i[published]
      end
    end

    state_machine auto_scopes: true do
      state :draft
      state :published

      event :publish do
        transitions from: :draft, to: :published
      end
    end

    def event_fired(current_state, new_state, event)
      version = V2::Version.increment_for_edition(
        edition: self,
        user: Current.user,
        state: new_state,
        field_diffs: generate_diff,
      )

      V2::DomainEvent.record(
        document: document,
        edition: self,
        user: Current.user,
        version: version,
        name: "edition.state_transition.succeeded",
        metadata: {
          previous_state: current_state,
          new_state: new_state,
          transition_name: event,
        },
      )
    end

    def in_progress?
      state.to_sym.in?(self.class.in_progress_states)
    end
  end
end
