RSpec.describe PublishIntentWorker do
  it "#perform adds a publishing intent to the Publishing API" do
    base_path = "/base-path"
    timestamp = Time.zone.now.to_s
    publish_intent = { foo: "bar" }
    gds_publishing_api = double

    allow(PublishingApi::PublishIntentPresenter).to receive(:new).with(base_path, timestamp.to_time).once.and_return(publish_intent)
    allow(Public::Services).to receive(:publishing_api).and_return(gds_publishing_api)

    expect(gds_publishing_api).to receive(:put_intent).once.with(base_path, publish_intent.as_json)

    PublishIntentWorker.new.perform(base_path, timestamp)
  end
end
