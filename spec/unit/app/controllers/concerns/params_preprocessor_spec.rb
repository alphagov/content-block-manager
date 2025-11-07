class ParamsPreprocessorClass
  include ParamsPreprocessor

  attr_reader :params

  def initialize(params)
    @params = params
  end
end

RSpec.describe ParamsPreprocessorClass do
  let(:params) { { object_type:, "something" => "else" } }

  let(:object) { ParamsPreprocessorClass.new(params) }

  describe "when object type is `telephones`" do
    let(:object_type) { "telephones" }

    it "should call the TelephonePreprocessor" do
      processed_params = double(:processed_params)
      preprocessor = double(:preprocessor, processed_params:)

      expect(ParamsPreprocessors::TelephonePreprocessor).to receive(:new)
                                                .with(params)
                                                .and_return(preprocessor)

      expect(processed_params).to eq(object.processed_params)
    end
  end
end
