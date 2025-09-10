require "test_helper"

class Shared::ErrorSummaryComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:object_with_no_errors) { ErrorSummaryTestObject.new("title", Time.zone.today) }
  let(:object_with_errors) { ErrorSummaryTestObject.new(nil, nil) }

  before do
    object_with_errors.validate
  end

  it "does not render if there are no errors on the object passed in" do
    render_inline(Shared::ErrorSummaryComponent.new(object: object_with_no_errors))
    assert_empty page.text
  end

  it "constructs a list of links which link to an id based on the objects class and attribute of the error" do
    render_inline(Shared::ErrorSummaryComponent.new(object: object_with_errors))

    first_link = page.all(".gem-c-error-summary__list-item")[0].find("a")
    second_link = page.all(".gem-c-error-summary__list-item")[1].find("a")
    third_link = page.all(".gem-c-error-summary__list-item")[2].find("a")

    assert_equal page.all(".gem-c-error-summary__list-item").count, 3
    assert_equal page.all(".gem-c-error-summary__list-item a").count, 3
    assert_equal first_link.text, "Title can't be blank"
    assert_equal first_link[:href], "#error_summary_test_object_title"
    assert_equal second_link.text, "Date can't be blank"
    assert_equal second_link[:href], "#error_summary_test_object_date"
    assert_equal third_link.text, "Date is invalid"
    assert_equal third_link[:href], "#error_summary_test_object_date"
  end

  it "overrides the class in the href with `parent class` if passed in" do
    render_inline(Shared::ErrorSummaryComponent.new(object: object_with_errors, parent_class: "parent_class"))

    first_link = page.all(".gem-c-error-summary__list-item")[0].find("a")
    second_link = page.all(".gem-c-error-summary__list-item")[1].find("a")
    third_link = page.all(".gem-c-error-summary__list-item")[2].find("a")

    assert_equal page.all(".gem-c-error-summary__list-item").count, 3
    assert_equal page.all(".gem-c-error-summary__list-item a").count, 3
    assert_equal first_link.text, "Title can't be blank"
    assert_equal first_link[:href], "#parent_class_title"
    assert_equal second_link.text, "Date can't be blank"
    assert_equal second_link[:href], "#parent_class_date"
    assert_equal third_link.text, "Date is invalid"
    assert_equal third_link[:href], "#parent_class_date"
  end

  it "constructs data modules for tracking analytics based on the class name and error message" do
    render_inline(Shared::ErrorSummaryComponent.new(object: object_with_errors))

    first_link = page.all(".gem-c-error-summary__list-item")[0].find("a")
    second_link = page.all(".gem-c-error-summary__list-item")[1].find("a")
    third_link = page.all(".gem-c-error-summary__list-item")[2].find("a")

    first_link_data = JSON.parse(first_link["data-ga4-auto"])
    second_link_data = JSON.parse(second_link["data-ga4-auto"])
    third_link_data = JSON.parse(third_link["data-ga4-auto"])

    assert_equal first_link["data-module"], "ga4-auto-tracker"
    assert_equal first_link_data["event_name"], "form_error"
    assert_equal first_link_data["type"], "Editing Error Summary Test Object"
    assert_equal first_link_data["text"], "Title can't be blank"
    assert_equal first_link_data["section"], "Title"
    assert_equal first_link_data["action"], "error"

    assert_equal second_link["data-module"], "ga4-auto-tracker"
    assert_equal second_link_data["event_name"], "form_error"
    assert_equal second_link_data["type"], "Editing Error Summary Test Object"
    assert_equal second_link_data["text"], "Date can't be blank"
    assert_equal second_link_data["section"], "Date"
    assert_equal second_link_data["action"], "error"

    assert_equal third_link["data-module"], "ga4-auto-tracker"
    assert_equal third_link_data["event_name"], "form_error"
    assert_equal third_link_data["type"], "Editing Error Summary Test Object"
    assert_equal third_link_data["text"], "Date is invalid"
    assert_equal third_link_data["section"], "Date"
    assert_equal third_link_data["action"], "error"
  end

  it "when an errors attribute is base it renders the error as text not a link" do
    object = ErrorSummaryTestObject.new("title", Time.zone.today)
    object.errors.add(:base, "This is a top level error that is agnostic of model level validations. It has probably been added by an updater service or a controller and does not link to an input.")
    render_inline(Shared::ErrorSummaryComponent.new(object:))

    assert_selector ".gem-c-error-summary__list-item a", count: 0
    assert_selector ".gem-c-error-summary__list-item span", text: "This is a top level error that is agnostic of model level validations. It has probably been added by an updater service or a controller and does not link to an input."
  end

  it "renders errors when 'ActiveModel::Errors' are passed in" do
    render_inline(Shared::ErrorSummaryComponent.new(object: object_with_errors.errors, parent_class: "error_summary_test_object"))

    first_link = page.all(".gem-c-error-summary__list-item")[0].find("a")
    second_link = page.all(".gem-c-error-summary__list-item")[1].find("a")
    third_link = page.all(".gem-c-error-summary__list-item")[2].find("a")

    assert_equal page.all(".gem-c-error-summary__list-item").count, 3
    assert_equal page.all(".gem-c-error-summary__list-item a").count, 3
    assert_equal first_link.text, "Title can't be blank"
    assert_equal first_link[:href], "#error_summary_test_object_title"
    assert_equal second_link.text, "Date can't be blank"
    assert_equal second_link[:href], "#error_summary_test_object_date"
    assert_equal third_link.text, "Date is invalid"
    assert_equal third_link[:href], "#error_summary_test_object_date"
  end

  it "renders errors when an array of 'ActiveModel::Error' objects are passed in" do
    render_inline(Shared::ErrorSummaryComponent.new(object: object_with_errors.errors.errors, parent_class: "error_summary_test_object"))

    first_link = page.all(".gem-c-error-summary__list-item")[0].find("a")
    second_link = page.all(".gem-c-error-summary__list-item")[1].find("a")
    third_link = page.all(".gem-c-error-summary__list-item")[2].find("a")

    assert_equal page.all(".gem-c-error-summary__list-item").count, 3
    assert_equal page.all(".gem-c-error-summary__list-item a").count, 3
    assert_equal first_link.text, "Title can't be blank"
    assert_equal first_link[:href], "#error_summary_test_object_title"
    assert_equal second_link.text, "Date can't be blank"
    assert_equal second_link[:href], "#error_summary_test_object_date"
    assert_equal third_link.text, "Date is invalid"
    assert_equal third_link[:href], "#error_summary_test_object_date"
  end
end

class ErrorSummaryTestObject
  include ActiveModel::Model
  attr_accessor :title, :date

  validates :title, :date, presence: true
  validate :date_is_a_date

  def initialize(title, date)
    @title = title
    @date = date
  end

  def date_is_a_date
    errors.add(:date, :invalid) unless date.is_a?(Date)
  end
end
