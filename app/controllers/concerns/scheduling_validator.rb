module SchedulingValidator
  extend ActiveSupport::Concern

  def validate_scheduled_edition
    case params[:schedule_publishing]
    when "schedule"
      validate_scheduled_publication_params

      @edition.update!(scheduled_publication_params)
      if @edition.valid?(:scheduling)
        @edition.save!
      else
        raise ActiveRecord::RecordInvalid, @edition
      end
    when "now"
      @edition.update!(scheduled_publication: nil, state: "draft")
      SchedulePublishingWorker.dequeue(@edition)
    else
      @edition.errors.add(:schedule_publishing, t("activerecord.errors.models.edition.attributes.schedule_publishing.blank"))
      raise ActiveRecord::RecordInvalid, @edition
    end
  end

  def validate_scheduled_publication_params
    error_base = "activerecord.errors.models.edition.attributes.scheduled_publication"
    if scheduled_publication_params.values.all?(&:blank?)
      @edition.errors.add(:scheduled_publication, t("#{error_base}.blank"))
    elsif scheduled_publication_time_params.all?(&:blank?)
      @edition.errors.add(:scheduled_publication, t("#{error_base}.time.blank"))
    elsif scheduled_publication_date_params.all?(&:blank?)
      @edition.errors.add(:scheduled_publication, t("#{error_base}.date.blank"))
    elsif scheduled_publication_params.values.any?(&:blank?)
      @edition.errors.add(:scheduled_publication, t("#{error_base}.invalid_date"))
    end

    raise ActiveRecord::RecordInvalid, @edition if @edition.errors.any?
  end

  def scheduled_publication_time_params
    [
      scheduled_publication_params["scheduled_publication(4i)"],
      scheduled_publication_params["scheduled_publication(5i)"],
    ]
  end

  def scheduled_publication_date_params
    [
      scheduled_publication_params["scheduled_publication(1i)"],
      scheduled_publication_params["scheduled_publication(2i)"],
      scheduled_publication_params["scheduled_publication(3i)"],
    ]
  end
end
