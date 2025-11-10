class ShowMethodsTestClass
  class << self
    def helper_method(method)
      @helper_methods ||= []
      @helper_methods << method
    end
  end

  include Workflow::ShowMethods
  include Rails.application.routes.url_helpers

  attr_reader :current_step, :previous_step

  def initialize(current_step:, previous_step:, edition:)
    @current_step = current_step
    @previous_step = previous_step
    @edition = edition
  end
end

RSpec.describe Workflow::ShowMethods, type: :integration do
  include Rails.application.routes.url_helpers

  describe "#back_path" do
    let(:edition) { build_stubbed(:edition) }

    it "returns the name of the previous step" do
      expected_step_name = "something"

      current_step = double("Workflow::Step")
      previous_step = double("Workflow::Step", name: expected_step_name)

      test_class = ShowMethodsTestClass.new(current_step:, previous_step:, edition:)

      expect(test_class.back_path).to eq(workflow_path(
                                           edition,
                                           step: expected_step_name,
                                         ))
    end
  end
end
