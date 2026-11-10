class BoardsController < ApplicationController
  before_action :set_board, only: %i[ show edit update destroy ]

  def index
    @boards = Board.includes(:cards).order(updated_at: :desc)
    @board = Board.new
  end

  def show
  end

  def create
    @board = Board.new(board_params)

    if @board.save
      redirect_to @board
    else
      render turbo_stream: turbo_stream.replace("new_board", partial: "boards/form", locals: { board: @board }),
             status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @board.update(board_params)
      redirect_to @board
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @board.destroy
    redirect_to boards_path, status: :see_other
  end

  private
    def set_board
      @board = Board.find(params[:id])
    end

    def board_params
      params.expect(board: [ :name, :description ])
    end
end
