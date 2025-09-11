require "test_helper"

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

class Workflow::ShowMethodsTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Rails.application.routes.url_helpers

  describe "#back_path" do
    let(:edition) { build_stubbed(:edition) }

    it "returns the name of the previous step" do
      expected_step_name = "something"

      current_step = mock("Workflow::Step")
      previous_step = mock("Workflow::Step", name: expected_step_name)

      test_class = ShowMethodsTestClass.new(current_step:, previous_step:, edition:)

      assert_equal test_class.back_path, workflow_path(
        edition,
        step: expected_step_name,
      )
    end
  end
end
