require "test_helper"

class BoardsControllerTest < ActionDispatch::IntegrationTest
  setup { @board = Board.create!(name: "Roadmap") }

  test "index lists boards" do
    get boards_path
    assert_response :success
    assert_select ".board-tile h2", text: "Roadmap"
  end

  test "show renders the three columns" do
    get board_path(@board)
    assert_response :success
    assert_select ".column", 3
  end

  test "create redirects to the new board" do
    post boards_path, params: { board: { name: "New" } }
    assert_redirected_to board_path(Board.find_by!(name: "New"))
  end

  test "create with a blank name replaces the form" do
    post boards_path, params: { board: { name: "" } }, as: :turbo_stream
    assert_response :unprocessable_entity
    assert_turbo_stream status: :unprocessable_entity, action: :replace, target: "new_board"
  end

  test "destroy deletes the board and its cards" do
    @board.cards.create!(title: "Gone")
    assert_difference -> { Board.count }, -1 do
      delete board_path(@board)
    end
    assert_equal 0, Card.count
  end
end
