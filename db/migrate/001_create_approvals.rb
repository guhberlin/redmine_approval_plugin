class CreateApprovals < ActiveRecord::Migration
  def change
    create_table :approvals do |t|
      t.references :changeset, :null => false
      t.string :approved_by, :null => false
      t.datetime :approved_on, :null => false
      t.references :user
    end
  end
end
