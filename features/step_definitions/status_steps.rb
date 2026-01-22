Then("I should see the status of the latest edition of the block") do
  edition = @content_block.document.editions.last
  should_show_the_status_for(edition: edition)
end

def should_show_the_status_for(edition:)
  should_see_status_for(state: edition.state)
end

Then(/I see that the edition is in ([^"]*) state/) do |state|
  should_see_status_for(state: state)
end

def should_see_status_for(state:)
  translated_state = I18n.t("edition.states.label.#{state}")

  within ".govuk-tag[title='Status: #{translated_state}']" do
    expect(page).to have_content(translated_state)
  end
end

Then(/I see a notification that the transition to ([^"]*) was successful/) do |state|
  message = case state
            when "Awaiting review"
              Edition::StateTransitionMessage.new(edition: Edition.last, state: :awaiting_review).to_s
            when "Awaiting factcheck"
              Edition::StateTransitionMessage.new(edition: Edition.last, state: :awaiting_factcheck).to_s
            when "deleted"
              Edition::StateTransitionMessage.new(edition: Edition.last, state: :deleted).to_s
            when "Published"
              Edition::StateTransitionMessage.new(edition: Edition.last, state: :published).to_s
            when "Scheduled"
              Edition::StateTransitionMessage.new(edition: Edition.last, state: :scheduled).to_s
            else
              raise "Unexpected state: '#{state}'"
            end

  within(".govuk-notification-banner--success") do
    expect(page).to have_content(message)
  end
end

Then(/I see an alert that the transition failed to transition to [^"]*/) do
  within(".gem-c-error-alert__message") do
    expect(page).to have_content(I18n.t("edition.states.transition_error"))
  end
end

Then(/the calls to action are suited to the ([^"]*) state/) do |state|
  case state.to_sym
  when :awaiting_review
    within ".actions" do
      expect(page).to have_link("Edit pension")
      expect(page).to have_no_button("Ready for 2i")
    end
  when :awaiting_factcheck
    within ".actions" do
      expect(page).to have_link("Edit pension")
      expect(page).to have_link("Delete draft")
    end
  when :published
    within ".actions" do
      expect(page).to have_link("Edit pension")
    end
  else
    raise "Only the 'awaiting_review' and 'awaiting_factcheck' states are supported currently"
  end
end
