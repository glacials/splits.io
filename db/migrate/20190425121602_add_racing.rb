class AddRacing < ActiveRecord::Migration[6.0]
  def change
    create_table :standard_races, id: :uuid do |t|
      t.belongs_to :category, foreign_key: true, null: false
      t.belongs_to :user,     foreign_key: true, null: false

      t.string   :status_text, null: false
      t.boolean  :listed,      null: false, default: true
      t.boolean  :invite,      null: false, default: false
      t.string   :auth_token,  null: true, index: {unique: true}
      t.string   :notes,       null: true

      # The limit param changes the precision of the datetime; 3 is millisecond accuracy
      t.datetime :started_at, limit: 3, null: true
      t.datetime :created_at, limit: 3, null: false
      t.datetime :updated_at, limit: 3, null: false
    end

    create_table :bingo_races, id: :uuid do |t|
      t.belongs_to :game, foreign_key: true, null: false
      t.belongs_to :user, foreign_key: true, null: false

      t.string   :status_text, null: false
      t.boolean  :listed,      null: false, default: true
      t.boolean  :invite,      null: false, default: false
      t.string   :auth_token,  null: true, index: {unique: true}
      t.string   :notes,       null: true
      t.string   :card,        null: false

      t.datetime :started_at, limit: 3, null: true
      t.datetime :created_at, limit: 3, null: false
      t.datetime :updated_at, limit: 3, null: false
    end

    create_table :randomizer_races, id: :uuid do |t|
      t.belongs_to :game, foreign_key: true, null: false
      t.belongs_to :user, foreign_key: true, null: false

      t.string   :status_text, null: false
      t.boolean  :listed,      null: false, default: true
      t.boolean  :invite,      null: false, default: false
      t.string   :auth_token,  null: true, index: {unique: true}
      t.string   :notes,       null: true
      t.string   :seed,        null: false

      t.datetime :started_at, limit: 3, null: true
      t.datetime :created_at, limit: 3, null: false
      t.datetime :updated_at, limit: 3, null: false
    end


    create_table :entrants, id: :uuid do |t|
      t.references :raceable, polymorphic: true, index: true, type: :uuid
      t.belongs_to :user,     foreign_key: true, index: true

      t.datetime :readied_at,   limit: 3, null: true
      t.datetime :finished_at,  limit: 3, null: true
      t.datetime :forfeited_at, limit: 3, null: true
      t.datetime :created_at,   limit: 3, null: false
      t.datetime :updated_at,   limit: 3, null: false
    end

    create_table :chat_rooms, id: :uuid do |t|
      t.belongs_to :raceable, polymorphic: true, index: true, type: :uuid

      t.boolean :locked, default: false, null: false

      t.timestamps
    end

    create_table :chat_messages, id: :uuid do |t|
      t.belongs_to :chat_room, foreign_key: true, null: false, type: :uuid
      t.belongs_to :user,      foreign_key: true, null: false

      t.text :body, null: false

      t.timestamps
    end
  end
end
