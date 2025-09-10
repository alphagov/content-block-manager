class User < ApplicationRecord
  include GDS::SSO::User

  serialize :permissions, coder: YAML, type: Array

  validates :name, presence: true

  def role
    "Editor"
  end

  module Permissions
    SIGNIN = "signin".freeze
  end

  def organisation
    organisation_content_id ? Organisation.find(organisation_content_id) : nil
  end
end
