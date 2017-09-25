require 'byebug'
require 'mtg_sdk'
require 'telegram/bot'
require_relative 'token'

token = Token::KEY

def get_cards(search_term)
  cards = MTG::Card.where(name: search_term).all[0..9]
  get_unique_cards(cards)
end

def get_unique_cards(cards)
  card_names, unique_cards = [], []
  cards.each do |card|
    next if card_names.include?(card.name) || card.image_url.nil?
    card_names << card.name
    unique_cards << card
  end
  unique_cards
end

def create_photo_instance(card)
  Telegram::Bot::Types::InlineQueryResultPhoto.new(
    id: card.id,
    photo_url: card.image_url,
    thumb_url: card.image_url
  )
end

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message
    when Telegram::Bot::Types::InlineQuery
      if !message.query.nil? && message.query.length > 3
        cards = get_cards(message.query)
        mapped_cards = cards.map { |card| create_photo_instance(card) }
        bot.api.answer_inline_query(
          inline_query_id: message.id,
          results: mapped_cards
        )
      end
    end
  end
end
