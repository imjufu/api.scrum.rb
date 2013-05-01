class Story < ActiveRecord::Base
  validates :label, :product, :presence => true
  validates :technical_point, :numericality => true, :allow_nil => true
  validates :functional_point, :numericality => true, :allow_nil => true
  belongs_to :product
end
