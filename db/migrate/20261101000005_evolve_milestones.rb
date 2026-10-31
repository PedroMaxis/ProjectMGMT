class EvolveMilestones < ActiveRecord::Migration[8.0]
  def change
    add_column :milestones, :completed_on, :date
  end
end
