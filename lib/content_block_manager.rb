module ContentBlockManager
  def self.product_name
    "Content Block Manager"
  end

  def self.support_url
    "#{Plek.external_url_for('support')}/general_request/new"
  end

  def self.support_email_address
    "feedback-content-modelling@digital.cabinet-office.gov.uk"
  end

  def self.admin_host
    @admin_host ||= URI(admin_root).host
  end

  def self.internal_admin_host
    @internal_admin_host ||=
      URI(Plek.find("content-block-manager")).host
  end

  def self.public_host
    @public_host ||= URI(public_root).host
  end

  def self.admin_root
    @admin_root ||= Plek.external_url_for("content-block-manager")
  end

  def self.public_root
    @public_root ||= Plek.website_root
  end

  def self.integration_or_staging?
    website_root = ENV.fetch("GOVUK_WEBSITE_ROOT", "")
    %w[integration staging].any? { |environment| website_root.include?(environment) }
  end
end
