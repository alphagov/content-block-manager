When("I am viewing the pre publication review page") do
  visit new_v2_time_period_edition_pre_publication_review_path(@time_period_edition)
end

When("I confirm that the block details are correct and continue") do
  check I18n.t("v2.edition.pre_publication_review.confirm")
  click_on "Create"
end
