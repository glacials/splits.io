class Api::V3::Games::CategoriesController < Api::V3::ApplicationController
  before_action :set_game, only: [:show]
  before_action :set_category, only: [:show]

  def show
    render json: CategoryBlueprint.render(@category, view: :api_v3, root: :category)
  end

  private

  def set_game
    @game = Game.joins(:srdc).find_by(speedrun_dot_com_games: {shortname: params[:game_id]}) || Game.find(params[:game_id])
  rescue ActiveRecord::RecordNotFound
    render status: :not_found, json: {status: 404, message: "Game with shortname or id '#{params[:game_id]}' not found."}
  end

  def set_category
    @category = Category.find_by(id: params[:id])
    return if @category.present?

    render status: :not_found, json: {status: 404, message: "No category with id '#{params[:id]}' found."}
  end
end
