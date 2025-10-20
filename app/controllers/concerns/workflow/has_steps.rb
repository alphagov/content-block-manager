module Workflow::HasSteps
  extend ActiveSupport::Concern
  include SchemaHelper

  class UnknownStepError < StandardError; end

  included do
    before_action :initialize_edition_and_schema
  end

  def steps
    @steps ||= Workflow::Steps.for(@edition, @schema)
  end

  def current_step
    steps[index]
  end

  def previous_step
    steps[index - 1]
  end

  def next_step
    steps[index + 1]
  end

private

  def initialize_edition_and_schema
    @edition = Edition.find(params[:id])
    @schema = Schema.find_by_block_type(@edition.document.block_type)
  end

  def index
    steps.find_index { |step| step.name == params[:step]&.to_sym } or raise UnknownStepError, "Step #{params[:step]} does not exist"
  end
end
