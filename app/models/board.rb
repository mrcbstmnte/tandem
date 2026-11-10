class Board < ApplicationRecord
  has_many :cards, -> { order(:position) }, dependent: :destroy

  validates :name, presence: true, length: { maximum: 60 }

  # Re-render every open copy of this board (Turbo 8 morphing) when it changes,
  # and refresh the boards index for anyone looking at it.
  broadcasts_refreshes
  after_commit -> { broadcast_refresh_later_to :boards }

  def cards_in(status)
    cards.select { |card| card.status == status.to_s }
  end
end
