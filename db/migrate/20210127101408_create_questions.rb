class CreateQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :questions do |t|
      t.references :content
      t.string :question 
      t.timestamps null: false
    end
  end
end
