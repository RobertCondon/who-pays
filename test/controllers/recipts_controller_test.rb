require "test_helper"

class ReciptsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @recipt = ReciptParser.import!(file_fixture("receipt.txt").read)
    @item = @recipt.recipt_items.find_by(name: "Char Unagi")
    @bob = Person.create!(name: "Bob")
  end

  test "index and show render" do
    get root_path
    assert_response :success
    get recipt_path(@recipt)
    assert_response :success
    assert_select ".r-totals .r-strong dd", text: "$ 917.00"
  end

  test "pay for selected items on behalf of an existing person" do
    items = @recipt.recipt_items.where(name: "ORION TAP").limit(3)
    post recipt_payment_path(@recipt), params: { item_ids: items.ids, paid_by_id: @bob.id }
    assert_redirected_to recipt_path(@recipt)
    assert items.reload.all? { |i| i.paid && i.paid_by == @bob }

    get recipt_path(@recipt)
    assert_select ".r-items .r-payer", text: "Bob", count: 3
    assert_equal [ [ @bob, 3900 ] ], @recipt.reload.payments
  end

  test "pay on behalf of a new person creates them" do
    assert_difference("Person.count") do
      post recipt_payment_path(@recipt), params: { item_ids: [ @item.id ], new_payer_name: " Cara " }
    end
    assert_equal "Cara", @item.reload.paid_by.name
  end

  test "new person name matching an existing person reuses them" do
    assert_no_difference("Person.count") do
      post recipt_payment_path(@recipt), params: { item_ids: [ @item.id ], new_payer_name: "bob" }
    end
    assert_equal @bob, @item.reload.paid_by
  end

  test "paying requires a payer and unpaid items" do
    post recipt_payment_path(@recipt), params: { item_ids: [ @item.id ] }
    assert_not @item.reload.paid

    set_menu = @recipt.recipt_items.find_by(name: "SET MENU")
    post recipt_payment_path(@recipt), params: { item_ids: [ set_menu.id ], paid_by_id: @bob.id }
    assert_nil set_menu.reload.paid_by
  end

  test "paid items have disabled checkboxes" do
    get recipt_path(@recipt)
    assert_select "input[name='item_ids[]'][disabled]", 11 # the pre-paid set menus
  end

  test "import pasted text" do
    assert_difference("Recipt.count") do
      post recipts_path, params: { text: file_fixture("receipt.txt").read, venue: "Izakaya" }
    end
    assert_equal "Izakaya", Recipt.last.venue
  end
end
