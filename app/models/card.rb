class Card < ApplicationRecord
  belongs_to :board, touch: true

  enum :status, { todo: 0, doing: 1, done: 2 }, validate: true

  validates :title, presence: true, length: { maximum: 140 }

  before_create :append_to_column

  # Any change to a card refreshes everyone else viewing the board.
  broadcasts_refreshes_to :board

  def self.status_label(status)
    { "todo" => "To do", "doing" => "In progress", "done" => "Done" }.fetch(status.to_s) { status.to_s.humanize }
  end

  # Moves the card into +status+ at the zero-based +position+ and
  # renumbers the destination column so positions stay contiguous.
  def move_to(status:, position:)
    transaction do
      column = board.cards.where(status: status).where.not(id: id).to_a
      column.insert(position.to_i.clamp(0, column.size), self)
      self.status = status

      column.each_with_index do |card, index|
        card.position = index
        card.save! if card.changed?
      end
    end
  end

  private
    def append_to_column
      self.position = board.cards.where(status: status).maximum(:position).to_i + 1
    end
end
