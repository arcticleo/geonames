class CreateGeonames < ActiveRecord::Migration
  def change
    create_table :geonames, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci' do |t|
      t.string :name, limit: 200
      t.string :asciiname, limit: 200
      t.string :alternatenames, limit: 10000
      t.decimal :latitude, precision: 10, scale: 5
      t.decimal :longitude, precision: 10, scale: 5
      t.string :feature_class, limit: 1
      t.string :feature_code, limit: 10
      t.string :country_code, limit: 2
      t.string :cc2, limit: 60
      t.string :admin1_code, limit: 20
      t.string :admin2_code, limit: 20
      t.string :admin3_code, limit: 20
      t.string :admin4_code, limit: 20
      t.integer :population, limit: 8
      t.integer :elevation
      t.integer :dem
      t.string :timezone, limit: 40
      t.datetime :modification_date

      t.timestamps null: false
    end
  end
end
