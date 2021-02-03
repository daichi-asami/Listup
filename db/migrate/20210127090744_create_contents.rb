class CreateContents < ActiveRecord::Migration[5.2]
  def change
    create_table :contents  do |t|
      t.string :title
      t.string :password_digest
      t.timestamps null: false
    end
  end
end
