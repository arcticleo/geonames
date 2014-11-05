class CreateFeatureCodes < ActiveRecord::Migration
  def change
    create_table :feature_codes do |t|
      t.string :feature_class, limit: 1
      t.string :feature_code, limit: 10
      t.string :name
      t.string :description

      t.timestamps null: false
    end
  end
end
