class CreatePostalCodes < ActiveRecord::Migration
  def change
    create_table :postal_codes, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci' do |t|
      t.string :country_code, limit: 2
      t.string :postal_code, limit: 20
      t.string :place_name, limit: 180
      t.string :admin1_name, limit: 100
      t.string :admin1_code, limit: 20
      t.string :admin2_name, limit: 100
      t.string :admin2_code, limit: 20
      t.string :admin3_name, limit: 100
      t.string :admin3_code, limit: 20
      t.decimal :latitude, precision: 10, scale: 5
      t.decimal :longitude, precision: 10, scale: 5
      t.integer :accuracy

      t.timestamps null: false
    end
    add_index(:postal_codes, :postal_code)
    add_index(:postal_codes, :place_name)
    add_index(:postal_codes, :admin1_name)
    add_index(:postal_codes, :admin1_code)
    add_index(:postal_codes, :admin2_name)
    add_index(:postal_codes, :admin2_code)
    add_index(:postal_codes, :admin3_name)
    add_index(:postal_codes, :admin3_code)
    add_index(:postal_codes, :latitude)
    add_index(:postal_codes, :longitude)
    add_index(:postal_codes, :accuracy)
  end
end
