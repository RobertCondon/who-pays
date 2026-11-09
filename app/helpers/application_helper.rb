module ApplicationHelper
  def money(cents)
    number_to_currency(cents.to_i / 100.0)
  end

  # Receipt-style amount: "1,467.00" (no currency sign).
  def amount(cents)
    number_with_precision(cents.to_i / 100.0, precision: 2, delimiter: ",")
  end
end
