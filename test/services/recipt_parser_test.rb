require "test_helper"

class ReciptParserTest < ActiveSupport::TestCase
  setup { @recipt = ReciptParser.import!(file_fixture("receipt.txt").read) }

  test "totals match the printed receipt" do
    assert_equal 146_700, @recipt.total_cents
    assert_equal 55_000, @recipt.paid_cents
    assert_equal 91_700, @recipt.balance_due_cents
  end

  test "expands quantities into one item per unit" do
    assert_equal 60, @recipt.recipt_items.count
    assert_equal 14, @recipt.recipt_items.where(name: "SAPPORO TAP.").count
    assert_equal [ 1500 ], @recipt.recipt_items.where(name: "SAPPORO TAP.").distinct.pluck(:price)
  end

  test "categorises items from the totals section" do
    assert_equal({ "Drinks" => 41, "Food" => 19 }, @recipt.recipt_items.group(:category).count)
  end

  test "reads header fields" do
    assert_equal "ALENA", @recipt.server
    assert_equal Time.zone.local(2026, 11, 6, 17, 55), @recipt.opened_at
  end

  test "payments tally what each payer has covered" do
    alice = Person.create!(name: "Alice")
    @recipt.recipt_items.where(name: "Takoyaki").update_all(paid: true, paid_by_id: alice.id)
    assert_equal [ [ alice, 1800 ] ], @recipt.reload.payments
    assert_equal 55_000, @recipt.paid_on_receipt_cents
  end
end
