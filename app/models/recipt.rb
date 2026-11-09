class Recipt < ApplicationRecord
  has_many :recipt_items, -> { order(:position, :id) }, inverse_of: :recipt, dependent: :destroy
  has_many_attached :photos # photos/scans of the paper receipt, kept for auditing

  def title
    venue.presence || "Receipt ##{id}"
  end

  def total_cents        = recipt_items.sum(&:price)
  def paid_cents         = recipt_items.select(&:paid).sum(&:price)
  def balance_due_cents  = total_cents - paid_cents

  def items_by_category
    recipt_items.group_by { |i| i.category.presence || "Other" }
  end

  # Who has paid how much so far, biggest first: [[person, cents], ...].
  # Items paid without a payer (e.g. pre-invoiced on the receipt) are left out.
  def payments
    recipt_items.select(&:paid_by).group_by(&:paid_by)
      .map { |person, items| [ person, items.sum(&:price) ] }
      .sort_by { |person, cents| [ -cents, person.name.downcase ] }
  end

  def paid_on_receipt_cents = recipt_items.select { |i| i.paid && !i.paid_by_id }.sum(&:price)
end
