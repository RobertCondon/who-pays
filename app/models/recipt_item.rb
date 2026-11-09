class ReciptItem < ApplicationRecord
  belongs_to :recipt
  belongs_to :paid_by, class_name: "Person", optional: true

  validates :name, presence: true
  validates :price, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
