class CreateSimpleStrings < ActiveRecord::Migration
  def change
    create_table :simple_strings do |t|

      t.timestamps
    end
  end
end
