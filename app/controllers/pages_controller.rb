class PagesController < ApplicationController
  def accessibility_statement; end

  def content_block_picker_demo
    block_picker_demo_initial_content
  end

private

  def block_picker_demo_initial_content
    @block_picker_demo_initial_content = if ENV["GOVUK_ENVIRONMENT"] == "integration"
                                           initial_content_with_integration_embed_codes
                                         else
                                           initial_content_without_embed_codes
                                         end
  end

  def initial_content_with_integration_embed_codes
    <<~MARKUP
      The full rate of new State Pension is {{embed:content_block_pension:new-state-pension/rates/full-new-state-pension-amount/amount}} a week.

      ### Contact us
      {{embed:content_block_contact:feedback}}
    MARKUP
  end

  def initial_content_without_embed_codes
    <<~MARKUP
      The full rate of new State Pension is £241.30 a week.

      ### Contact us
      Email: general.enquiries@example.gov.uk
      We will aim to respond to your query within 2 business days.

      Phone: 020 3738 6000
    MARKUP
  end
end
