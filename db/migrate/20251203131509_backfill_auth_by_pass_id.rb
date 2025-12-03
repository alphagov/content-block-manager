class BackfillAuthByPassId < ActiveRecord::Migration[8.0]
  def change
    Edition.all.find_each do |edition|
      edition.update_column(:auth_bypass_id, SecureRandom.uuid)
    end
  end
end
