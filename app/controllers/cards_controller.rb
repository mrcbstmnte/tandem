class CardsController < ApplicationController
  before_action :set_board
  before_action :set_card, only: %i[ edit update destroy move ]

  def create
    @card = @board.cards.build(card_params)

    respond_to do |format|
      if @card.save
        format.turbo_stream
        format.html { redirect_to @board }
      else
        format.turbo_stream { render :create, status: :unprocessable_entity }
        format.html { redirect_to @board, alert: @card.errors.full_messages.to_sentence }
      end
    end
  end

  def edit
  end

  def update
    if @card.update(card_params.slice(:title))
      render @card
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @card.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @board, status: :see_other }
    end
  end

  # Called by the drag-and-drop Stimulus controller. The DOM is already in
  # place on the dragging client, so we only send back the column counts.
  def move
    @card.move_to(status: params.require(:status), position: params.require(:position))
    @board.cards.reset
    render :counts, formats: :turbo_stream
  rescue ArgumentError, ActiveRecord::RecordInvalid
    head :unprocessable_entity
  end

  private
    def set_board
      @board = Board.find(params[:board_id])
    end

    def set_card
      @card = @board.cards.find(params[:id])
    end

    def card_params
      params.expect(card: [ :title, :status ])
    end
end
