Around("@freeze_time") do |_scenario, block|
  Timecop.freeze do
    block.call
  end
end
