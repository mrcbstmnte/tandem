require "test_helper"

class CardTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  setup do
    @board = Board.create!(name: "Test")
    @a, @b, @c = %w[A B C].map { |title| @board.cards.create!(title: title) }
  end

  test "new cards are appended to the end of their column" do
    assert_equal %w[A B C], titles(:todo)
  end

  test "move_to reorders within a column" do
    @c.move_to(status: "todo", position: 0)
    assert_equal %w[C A B], titles(:todo)
  end

  test "move_to moves a card to another column at the given position" do
    @board.cards.create!(title: "D", status: :done)
    @b.move_to(status: "done", position: 0)

    assert_equal %w[A C], titles(:todo)
    assert_equal %w[B D], titles(:done)
  end

  test "move_to clamps out-of-range positions" do
    @a.move_to(status: "doing", position: 99)
    assert_equal %w[A], titles(:doing)
  end

  test "move_to rejects unknown statuses" do
    assert_raises(ActiveRecord::RecordInvalid) { @a.move_to(status: "nope", position: 0) }
    assert_equal "todo", @a.reload.status
  end

  test "changes broadcast a refresh to the board" do
    assert_turbo_stream_broadcasts(@board) do
      perform_enqueued_jobs { @a.update!(title: "Renamed") }
    end
  end

  private
    def titles(status)
      @board.cards.reload.where(status: status).pluck(:title)
    end
end
