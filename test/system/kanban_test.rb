require "application_system_test_case"

class KanbanTest < ApplicationSystemTestCase
  setup do
    @board = Board.create!(name: "Launch")
    @board.cards.create!(title: "Write README")
    @board.cards.create!(title: "Ship it", status: :doing)
  end

  test "adding a card appends it without a page reload" do
    visit board_path(@board)
    marker = page.evaluate_script("window.marker = Math.random()")

    within "#new_card_todo" do
      fill_in "card[title]", with: "Record demo\n"
    end

    assert_selector "#cards_todo .card", text: "Record demo"
    assert_selector "#count_todo", text: "2"
    assert_field "card[title]", with: "", count: 3
    assert_equal marker, page.evaluate_script("window.marker")
  end

  test "editing a card inline" do
    visit board_path(@board)
    card = find(".card", text: "Write README")
    card.hover
    card.click_on "Edit"

    within ".card-form" do
      fill_in "card[title]", with: "Write a great README"
      click_on "Save"
    end

    assert_selector ".card", text: "Write a great README"
    assert_no_selector ".card textarea"
  end

  test "dragging a card to another column persists it" do
    visit board_path(@board)
    find(".card", text: "Write README").drag_to find("#cards_done"), html5: true

    assert_selector "#cards_done .card", text: "Write README"
    assert_selector "#count_done", text: "1"
    assert_selector "#count_todo", text: "0"
    assert_equal "done", Card.find_by!(title: "Write README").status
  end

  test "changes made in one browser appear live in another" do
    visit board_path(@board)
    connect_turbo_cable_stream_sources

    using_session :teammate do
      visit board_path(@board)
      within("#new_card_doing") { fill_in "card[title]", with: "Pairing session\n" }
      assert_selector "#cards_doing .card", text: "Pairing session"
    end

    assert_selector "#cards_doing .card", text: "Pairing session"
    assert_selector "#count_doing", text: "2"
  end
end
