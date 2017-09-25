require 'byebug'
require 'mtg_sdk'
require 'telegram/bot'
require_relative 'token'

token = Token::KEY

def get_cards(search_term)
  cards = MTG::Card.where(name: search_term).all
  card_names = []
  unique_cards = []
  cards.each do |card|
    next if card_names.include?(card.name) || card.image_url.nil?
    card_names << card.name
    unique_cards << card
  end
  unique_cards.map{|card| card.image_url}
end

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    if !message.text.nil?
      cmd = message.text.split(" ")[0]
      case cmd
      when '/card'
        search_term = message.text.split(" ")[1..-1].join(" ")
        cards = get_cards(search_term)
        cards.each do |card_url|
          bot.api.send_message(chat_id: message.chat.id, text: card_url)
        end
      end
    end
  end
end
