class CreateDialogueLines < ActiveRecord::Migration
  def self.up
    create_table :dialogue_lines do |t|
      t.text :content
      
#      These next three are necessary for awesome_nested_set
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt

#      These next two are necessary for has_many_polymorphs
      t.references :line_generator, :polymorphic => true
      t.references :room

      t.boolean    :visible, :default=>1

      t.timestamps
    end
  end

  def self.down
    drop_table :dialogue_lines
  end
end
