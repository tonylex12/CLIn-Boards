require "json"
require_relative "card"

class List
  attr_accessor :name, :id, :cards
  @@id_count = 0
  def initialize(name:, id: nil, cards: [])
    @name = name
    @id = id || (@@id_count + 1)
    @@id_count = @id
    @cards = cards.map { |card_hash| Card.new(**card_hash)}
  end

  def details
    [@id, @name, @cards.size]
  end
  
  def to_json(_arg)
    { id: @id, name: @name, cards: @cards }.to_json
  end

  def update(name:)
    @name = name unless name.empty?
  end

end