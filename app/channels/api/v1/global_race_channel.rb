class Api::V1::GlobalRaceChannel < ApplicationCable::Channel
  def subscribed
    stream_from('global_channel')
    return unless params[:state] == '1'

    # send all current active races
  end

  def unsubscribed
    stop_all_streams
  end

  def create_race(data)
    if current_user.nil?
      transmit(Api::V1::WebsocketMessageBlueprint.render_as_hash(Api::V1::WebsocketMessage.new(
        'race_creation_error',
        message: 'Must be authenticated as a user to make a race (you are anonymous)'
      )))
      return
    end
    if data['race_type'].blank?
      transmit(Api::V1::WebsocketMessageBlueprint.render_as_hash(Api::V1::WebsocketMessage.new(
        'race_creation_error',
        message: "Invalid race_type, must be one of: #{Raceable.RACE_TYPES.map(&:to_s).join(', ')}"
      )))
      return
    end

    race_type = Raceable.race_from_type(data['race_type'])
    return if race_type.nil?

    race = race_type.new
    case race
    when Race
      category = Category.find_by(id: data['category_id'])

      race.category = category
    when Bingo
      game = Game.find_by(id: data['game_id'])

      race.game = game
      race.card_url = data['bingo_card']
    when Randomizer
      game = Game.find_by(id: data['game_id'])

      race.game = game
      race.seed = data['seed']
    end

    race.owner = current_user
    race.visibility = data['visibility'] if race.class.visibilities.key?(data['visibility'])
    race.notes = data['notes']
    if race.save
      race.entrants.create(user: current_user)
      ws_msg = Api::V1::WebsocketMessage.new(
        'race_creation_success',
        message: 'Race has been created',
        race:    Api::V4::RaceBlueprint.render_as_hash(race),
        path:    Rails.application.routes.url_helpers.polymorphic_path(race)
      )
      transmit(Api::V1::WebsocketMessageBlueprint.render_as_hash(ws_msg))
    else
      ws_msg = Api::V1::WebsocketMessage.new(
        'race_creation_error',
        message: race.errors.full_messages.to_sentence
      )
      transmit(Api::V1::WebsocketMessageBlueprint.render_as_hash(ws_msg))
    end
  end
end
