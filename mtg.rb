require 'byebug'
require 'mtg_sdk'
require 'telegram/bot'
require_relative 'token'

token = Token::KEY

def get_cards(search_term)
  cards = MTG::Card.where(name: search_term).all[0..5]
  card_names = []
  unique_cards = []
  cards.each do |card|
    next if card_names.include?(card.name) || card.image_url.nil?
    card_names << card.name
    unique_cards << card
  end
  unique_cards
end

Telegram::Bot::Client.run(token) do |bot|
  inline_query = Telegram::Bot::Types::InlineQuery
  bot.listen do |message|
    case message
    when inline_query
      if !message.query.nil? && message.query.length > 4
        cards = get_cards(message.query)
        mapped_cards = cards.map do |card|
          Telegram::Bot::Types::InlineQueryResultPhoto.new(
            id: card.id,
            photo_url: card.image_url,
            thumb_url: card.image_url
          )
        end
        bot.api.answer_inline_query(inline_query_id: message.id, results: mapped_cards)
      end
    end
  end
end
