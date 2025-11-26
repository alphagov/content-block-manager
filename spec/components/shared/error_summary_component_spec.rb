RSpec.describe Shared::ErrorSummaryComponent, type: :component do
  let(:object_with_no_errors) { ErrorSummaryTestObject.new("title", Time.zone.today) }
  let(:object_with_errors) { ErrorSummaryTestObject.new(nil, nil) }

  before do
    object_with_errors.validate
  end

  it "does not render if there are no errors on the object passed in" do
    render_inline(described_class.new(object: object_with_no_errors))
    expect(page.text).to be_empty
  end

  it "constructs a list of links which link to an id based on the objects class and attribute of the error" do
    render_inline(described_class.new(object: object_with_errors))

    first_link = page.all(".gem-c-error-summary__list-item")[0].find("a")
    second_link = page.all(".gem-c-error-summary__list-item")[1].find("a")
    third_link = page.all(".gem-c-error-summary__list-item")[2].find("a")

    expect(3).to eq(page.all(".gem-c-error-summary__list-item").count)
    expect(3).to eq(page.all(".gem-c-error-summary__list-item a").count)
    expect("Title can't be blank").to eq(first_link.text)
    expect("#error_summary_test_object_title").to eq(first_link[:href])
    expect("Date can't be blank").to eq(second_link.text)
    expect("#error_summary_test_object_date").to eq(second_link[:href])
    expect("Date is invalid").to eq(third_link.text)
    expect("#error_summary_test_object_date").to eq(third_link[:href])
  end

  it "overrides the class in the href with `parent class` if passed in" do
    render_inline(described_class.new(object: object_with_errors, parent_class: "parent_class"))

    first_link = page.all(".gem-c-error-summary__list-item")[0].find("a")
    second_link = page.all(".gem-c-error-summary__list-item")[1].find("a")
    third_link = page.all(".gem-c-error-summary__list-item")[2].find("a")

    expect(3).to eq(page.all(".gem-c-error-summary__list-item").count)
    expect(3).to eq(page.all(".gem-c-error-summary__list-item a").count)
    expect("Title can't be blank").to eq(first_link.text)
    expect("#parent_class_title").to eq(first_link[:href])
    expect("Date can't be blank").to eq(second_link.text)
    expect("#parent_class_date").to eq(second_link[:href])
    expect("Date is invalid").to eq(third_link.text)
    expect("#parent_class_date").to eq(third_link[:href])
  end

  it "constructs data modules for tracking analytics based on the class name and error message" do
    render_inline(described_class.new(object: object_with_errors))

    first_link = page.all(".gem-c-error-summary__list-item")[0].find("a")
    second_link = page.all(".gem-c-error-summary__list-item")[1].find("a")
    third_link = page.all(".gem-c-error-summary__list-item")[2].find("a")

    first_link_data = JSON.parse(first_link["data-ga4-auto"])
    second_link_data = JSON.parse(second_link["data-ga4-auto"])
    third_link_data = JSON.parse(third_link["data-ga4-auto"])

    expect("ga4-auto-tracker").to eq(first_link.[]("data-module"))
    expect("form_error").to eq(first_link_data.[]("event_name"))
    expect("Editing Error Summary Test Object").to eq(first_link_data.[]("type"))
    expect("Title can't be blank").to eq(first_link_data.[]("text"))
    expect("Title").to eq(first_link_data.[]("section"))
    expect("error").to eq(first_link_data.[]("action"))

    expect("ga4-auto-tracker").to eq(second_link.[]("data-module"))
    expect("form_error").to eq(second_link_data.[]("event_name"))
    expect("Editing Error Summary Test Object").to eq(second_link_data.[]("type"))
    expect("Date can't be blank").to eq(second_link_data.[]("text"))
    expect("Date").to eq(second_link_data.[]("section"))
    expect("error").to eq(second_link_data.[]("action"))

    expect("ga4-auto-tracker").to eq(third_link.[]("data-module"))
    expect("form_error").to eq(third_link_data.[]("event_name"))
    expect("Editing Error Summary Test Object").to eq(third_link_data.[]("type"))
    expect("Date is invalid").to eq(third_link_data.[]("text"))
    expect("Date").to eq(third_link_data.[]("section"))
    expect("error").to eq(third_link_data.[]("action"))
  end

  it "when an errors attribute is base it renders the error as text not a link" do
    object = ErrorSummaryTestObject.new("title", Time.zone.today)
    object.errors.add(:base, "This is a top level error that is agnostic of model level validations. It has probably been added by an updater service or a controller and does not link to an input.")
    render_inline(described_class.new(object:))

    expect(page).to have_css ".gem-c-error-summary__list-item a", count: 0
    expect(page).to have_css ".gem-c-error-summary__list-item span", text: "This is a top level error that is agnostic of model level validations. It has probably been added by an updater service or a controller and does not link to an input."
  end

  it "renders errors when 'ActiveModel::Errors' are passed in" do
    render_inline(described_class.new(object: object_with_errors.errors, parent_class: "error_summary_test_object"))

    first_link = page.all(".gem-c-error-summary__list-item")[0].find("a")
    second_link = page.all(".gem-c-error-summary__list-item")[1].find("a")
    third_link = page.all(".gem-c-error-summary__list-item")[2].find("a")

    expect(3).to eq(page.all(".gem-c-error-summary__list-item").count)
    expect(3).to eq(page.all(".gem-c-error-summary__list-item a").count)
    expect("Title can't be blank").to eq(first_link.text)
    expect("#error_summary_test_object_title").to eq(first_link[:href])
    expect("Date can't be blank").to eq(second_link.text)
    expect("#error_summary_test_object_date").to eq(second_link[:href])
    expect("Date is invalid").to eq(third_link.text)
    expect("#error_summary_test_object_date").to eq(third_link[:href])
  end

  it "renders errors when an array of 'ActiveModel::Error' objects are passed in" do
    render_inline(described_class.new(object: object_with_errors.errors.errors, parent_class: "error_summary_test_object"))

    first_link = page.all(".gem-c-error-summary__list-item")[0].find("a")
    second_link = page.all(".gem-c-error-summary__list-item")[1].find("a")
    third_link = page.all(".gem-c-error-summary__list-item")[2].find("a")

    expect(3).to eq(page.all(".gem-c-error-summary__list-item").count)
    expect(3).to eq(page.all(".gem-c-error-summary__list-item a").count)
    expect("Title can't be blank").to eq(first_link.text)
    expect("#error_summary_test_object_title").to eq(first_link[:href])
    expect("Date can't be blank").to eq(second_link.text)
    expect("#error_summary_test_object_date").to eq(second_link[:href])
    expect("Date is invalid").to eq(third_link.text)
    expect("#error_summary_test_object_date").to eq(third_link[:href])
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
