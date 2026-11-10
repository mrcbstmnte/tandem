require "test_helper"

class CardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @board = Board.create!(name: "Test")
    @card = @board.cards.create!(title: "First")
  end

  test "create responds with turbo streams" do
    assert_difference -> { @board.cards.count } do
      post board_cards_path(@board), params: { card: { title: "Second", status: "doing" } }, as: :turbo_stream
    end

    assert_response :success
    assert_turbo_stream action: :append, target: "cards_doing"
    assert_turbo_stream action: :replace, target: "new_card_doing"
  end

  test "create with a blank title re-renders the form" do
    assert_no_difference -> { Card.count } do
      post board_cards_path(@board), params: { card: { title: "", status: "todo" } }, as: :turbo_stream
    end

    assert_response :unprocessable_entity
    assert_turbo_stream status: :unprocessable_entity, action: :replace, target: "new_card_todo"
  end

  test "update renders the card frame" do
    patch board_card_path(@board, @card), params: { card: { title: "Edited" } }

    assert_response :success
    assert_select "turbo-frame#card_#{@card.id}", text: /Edited/
  end

  test "move persists the new column and returns counts" do
    patch move_board_card_path(@board, @card), params: { status: "done", position: 0 }, as: :json

    assert_response :success
    assert_equal "done", @card.reload.status
    assert_turbo_stream action: :replace, target: "count_done"
  end

  test "move with an unknown status is rejected" do
    patch move_board_card_path(@board, @card), params: { status: "nope", position: 0 }, as: :json
    assert_response :unprocessable_entity
  end

  test "destroy removes the card" do
    assert_difference -> { Card.count }, -1 do
      delete board_card_path(@board, @card), as: :turbo_stream
    end
    assert_turbo_stream action: :remove, target: "card_#{@card.id}"
  end
end
