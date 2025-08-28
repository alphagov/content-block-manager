class User < ApplicationRecord
  include GDS::SSO::User

  serialize :permissions, coder: YAML, type: Array

  validates :name, presence: true

  scope :enabled, -> { where(disabled: false) }

  module Permissions
    SIGNIN = "signin".freeze
    DEPARTMENTAL_EDITOR = "Editor".freeze
    MANAGING_EDITOR = "Managing Editor".freeze
    GDS_EDITOR = "GDS Editor".freeze
    VIP_EDITOR = "VIP Editor".freeze
    PUBLISH_SCHEDULED_EDITIONS = "Publish scheduled editions".freeze
    GDS_ADMIN = "GDS Admin".freeze
    SIDEKIQ_ADMIN = "Sidekiq Admin".freeze
    VISUAL_EDITOR_PRIVATE_BETA = "Visual editor private beta".freeze
  end

  def role
    if gds_editor? then "GDS Editor"
    elsif departmental_editor? then "Departmental Editor"
    elsif managing_editor? then "Managing Editor"
    else
      "Writer"
    end
  end

  def departmental_editor?
    has_permission?(Permissions::DEPARTMENTAL_EDITOR)
  end

  def managing_editor?
    has_permission?(Permissions::MANAGING_EDITOR)
  end

  def gds_editor?
    has_permission?(Permissions::GDS_EDITOR)
  end

  def vip_editor?
    has_permission?(Permissions::VIP_EDITOR)
  end

  def gds_admin?
    has_permission?(Permissions::GDS_ADMIN)
  end

  def can_see_visual_editor_private_beta?
    has_permission?(Permissions::VISUAL_EDITOR_PRIVATE_BETA)
  end

  def has_email?
    email.present?
  end

  def editable_by?(user)
    user.gds_editor?
  end

  def fuzzy_last_name
    name.split(/ +/, 2).last
  end
end
