require "json"
require_relative "board"
require_relative "list"

class Store
  attr_reader :boards
  def initialize(filename)
    @filename = filename
    @boards = load_boards 
  end

  def add_board(board)
    new_board = Board.new(**board)
    @boards << new_board
    save_info
  end

  def update_board(id, data)
    board = find_board(id)
    board.update(**data)
    save_info
  end

  def delete_board(id)
    board = find_board(id)
    @boards.delete(board)
    save_info
  end

  def find_board(id)
    @boards.find { |board| board.id == id }
  end

  def find_card(id, lists)
    lists.each do |list|
      card = list.cards.find { |card| card.id == id }
      return card if card
    end
    nil
  end

  def add_check_item(card, check_item)
    card.checklist << check_item
    save_info
  end

  def toggle_check_item(id, card)
    card.checklist[(id - 1)][:completed] = !card.checklist[(id - 1)][:completed]
    save_info
  end

  def delete_check_item(id, card)
    card.checklist.delete_at(id - 1)
    save_info
  end

  def add_card(lists, name, card)
    list = lists.find { |list| list.name == name }
    new_card = Card.new(**card)
    list.cards << new_card
    save_info
  end

  def update_card(list, card, id)
    list.cards.each do |c|
      if c.id == id
        c.update(**card)
        save_info
        return
      end
    end

  end

  def delete_card(id, lists)
    lists.each do |list|
      list.cards.each do |card|
        if card.id == id
          list.cards.delete(card)
          save_info
          return
        end
      end
    end
  end

  def add_list(list)
    new_list = List.new(**list)
    @boards.last.lists << new_list
    save_info
  end

  def update_list(name, board, list)
    board.lists.each do |l|
      if l.name == name
        l.update(**list)
        save_info
        return
      end
    end
  end

  def delete_list(name, board)
    list = board.lists.find { |ele| ele.name == name }
    board.lists.delete(list)
    save_info
  end

  private

  def load_boards
    return [] unless File.exist?(@filename)
    data = JSON.parse(File.read(@filename), symbolize_names: true)
    data.map { |board| Board.new(**board) }
  end

  def save_info
    File.write(@filename, @boards.to_json)
  end

end