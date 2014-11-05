class FeatureCode < ActiveRecord::Base
  has_many :geonames

  validates_presence_of :feature_class
  validates_presence_of :feature_code
end
