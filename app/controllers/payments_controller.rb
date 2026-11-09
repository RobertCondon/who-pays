# Pays for a selection of unpaid items on a receipt, on behalf of one person.
# The payer is an existing person (paid_by_id) or a new one (new_payer_name).
class PaymentsController < ApplicationController
  def create
    recipt = Recipt.find(params[:recipt_id])
    items = recipt.recipt_items.where(id: Array(params[:item_ids]), paid: false)
    return redirect_to(recipt, alert: "Select some unpaid items first.", status: :see_other) if items.none?

    payer = find_or_create_payer
    return redirect_to(recipt, alert: "Pick who is paying.", status: :see_other) unless payer&.persisted?

    count, cents = items.size, items.sum(:price)
    items.update_all(paid: true, paid_by_id: payer.id)
    redirect_to recipt, status: :see_other,
      notice: "#{payer.name} paid #{helpers.money(cents)} for #{helpers.pluralize(count, "item")}."
  end

  private

  def find_or_create_payer
    name = params[:new_payer_name].to_s.strip
    if name.present?
      Person.where("lower(name) = ?", name.downcase).first || Person.create(name:)
    else
      Person.find_by(id: params[:paid_by_id])
    end
  end
end
