class Person < ApplicationRecord
  has_many :paid_items, class_name: "ReciptItem", foreign_key: :paid_by_id, dependent: :nullify

  normalizes :name, with: ->(n) { n.strip.squeeze(" ") }
  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
