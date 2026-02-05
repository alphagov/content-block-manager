class User < ApplicationRecord
  include GDS::SSO::User

  has_many :domain_events

  serialize :permissions, coder: YAML, type: Array

  validates :name, presence: true

  def is_e2e_user?
    ENV.fetch("E2E_USER_EMAILS", "")
       .split(",")
       .include?(email)
  end

  def role
    "Editor"
  end

  module Permissions
    SIGNIN = "signin".freeze
    PRE_RELEASE_FEATURES_PERMISSION = "pre_release_features".freeze
    SHOW_ALL_CONTENT_BLOCK_TYPES = "show_all_content_block_types".freeze
  end

  def organisation
    organisation_content_id ? Organisation.find(organisation_content_id) : nil
  end
end
