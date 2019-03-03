class Api::V4::GamesController < Api::V4::ApplicationController
  before_action :set_game, only: [:show]

  def index
    if params[:search].blank?
      render status: :bad_request, json: {status: 400, message: 'You must supply a `search` term.'}
      return
    end
    @games = Game.search(params[:search]).includes(:categories)
    render json: GameBlueprint.render(@games, view: :api_v4, root: :games, toplevel: :game)
  end

  def show
    render json: GameBlueprint.render(@game, view: :api_v4, root: :game, toplevel: :game)
  end

  private

  def set_games
    @games = Game.search(params[:search])
  end
end
