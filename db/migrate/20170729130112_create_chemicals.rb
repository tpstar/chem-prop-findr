class CreateChemicals < ActiveRecord::Migration[5.0]
  def change
    create_table :chemicals do |t|
      t.string :name
      t.string :formula
      t.string :fw
      t.string :mp
      t.string :bp
      t.string :density
    end
  end
end
