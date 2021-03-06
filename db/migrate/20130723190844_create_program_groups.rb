class CreateProgramGroups < ActiveRecord::Migration
  def change
    create_table :program_groups do |t|
      t.string :name
      t.references :restriction
      t.integer :value
      t.references :parent, :polymorphic => true

      t.timestamps
    end
  end
end
