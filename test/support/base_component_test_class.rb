class BaseComponentTestClass < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:helper_stub) { stub(:helpers) }

  before do
    described_class.any_instance.stubs(:helpers).returns(helper_stub)
    helper_stub.stubs(:hint_text).returns(nil)
    helper_stub.stubs(:humanized_label).returns("Translated label")
  end
end
