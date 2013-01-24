class AddSomeStringToSimpleString < ActiveRecord::Migration
  def change
    add_column :simple_strings, :some_string, :string
  end
end
