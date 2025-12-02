class RennameAwaiting2iStatesToAwaitingReview < ActiveRecord::Migration[8.0]
  def change
    Edition.where(state: "awaiting_2i")
           .update_all(state: "awaiting_review")
  end
end
