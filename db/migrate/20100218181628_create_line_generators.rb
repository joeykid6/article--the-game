class CreateLineGenerators < ActiveRecord::Migration
  def self.up
    create_table :line_generators do |t|
      t.string :line_generator_type


      t.timestamps
    end

    seed = LineGenerator.create(:line_generator_type => 'GameRobot')
    seed.save

    seed = LineGenerator.create(:line_generator_type => 'Guide')
    seed.save

    seed = LineGenerator.create(:line_generator_type => 'Speaker')
    seed.save

  end

  def self.down
    drop_table :line_generators
  end
end
