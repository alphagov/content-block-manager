And("I tick to show the lower threshold") do
  labels = all("label", text: I18n.t("edition.labels.tax.things_taxed.rates.bands.lower_threshold.show"))
  labels.last.click
end

And("I tick to show the upper threshold") do
  labels = all("label", text: I18n.t("edition.labels.tax.things_taxed.rates.bands.upper_threshold.show"))
  labels.last.click
end
