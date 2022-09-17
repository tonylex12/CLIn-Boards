require "json"
require_relative "list"

class Board
  attr_accessor :name, :description, :id, :lists
  @@id_count = 0
  def initialize(name:, description:, id: nil, lists: [])
    @name = name
    @description = description
    @id = id || (@@id_count + 1)
    @@id_count = @id
    @lists = lists.map { |list_hash| List.new(**list_hash) }
  end

  def details
    [@id, @name, @description, lists_categories(@lists)]
  end

  def to_json(_arg)
    { id: @id, name: @name, description: @description, lists: @lists }.to_json
  end

  def lists_categories(lists)
    result = []
    lists.each do |list|
      result << "#{list.name}(#{list.cards.size})"
    end
    result.join(", ")
  end

  def update(name:, description:)
    @name = name unless name.empty?
    @description = description unless description.empty?
  end
end