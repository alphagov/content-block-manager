module CheckAssertions
  def after_teardown
    super

    return if skipped? || error?

    raise(Minitest::Assertion, "Test is missing assertions") if assertions.zero?
  end
end

Minitest::Test.prepend(CheckAssertions)
