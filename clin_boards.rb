require "json"
require "terminal-table"
require_relative "store"
require_relative "list"
require_relative "card"

class ClinBoards
  def initialize(filename = "store.json")
    @store = Store.new(filename)
  end

  def start
    action = ""
    until action == "exit"
      print_table(
        list: @store.boards,
        title: "CLIn Boards",
        headings: ["ID", "Name", "Description", "Lists"]
      )

      action, id = menu("Board options: ", ["create", "show ID", "update ID", "delete ID"], "exit")

      case action
      when "create" then create_board
      when "show" then show_board(id)
      when "update" then update_board(id)
      when "delete" then delete_board(id)
      when "exit" then goodbye
      else
        puts "Invalid action"
      end
    end
    puts action
  end

  def print_table(list:, title:, headings:)
    table = Terminal::Table.new
    table.title = title
    table.headings = headings
    table.rows = list.map(&:details)
    puts table
  end

  def menu(prompt, options, ending)
    print prompt
    print options.join(" | ")
    print "\n"
    puts ending
    print "> "
    action, id = gets.chomp.split
    [action, id.to_i]
  end

  def show_menu(list_options, card_options)
    print "List options: "
    print list_options.join(" | ")
    print "\n"
    print "Card options: "
    print card_options.join(" | ")
    print "\n"
    puts "back"
    print "> "
    action, id, *extra = gets.chomp.split
    if action == "update-list" || action == "delete-list"
      if extra.empty?
        name = id
        [action, name]
      else
        name = id + " " + [*extra].join(" ")
        [action, name]
      end
    else
      [action, id.to_i]
    end
  end

  def goodbye
    print "#{'#' * 36}\n"
    print "##{' ' * 3}Thanks for using CLIN Boards#{' ' * 3}#\n"
    print "#{'#' * 36}\n"
  end

  def board_form
    print "Name: "
    name = gets.chomp
    print "Description: "
    description = gets.chomp
    { name: name, description: description }
  end

  def list_form
    print "Name: "
    name = gets.chomp
    { name: name }
  end

  def card_form
    print "Title: "
    title = gets.chomp
    print "Members: "
    members = gets.chomp
    print "Labels: "
    labels = gets.chomp
    print "Due Date: "
    due_date = gets.chomp
    { title: title, members: members.split(", "), labels: labels.split(", "), due_date: due_date }
  end

  def check_item_form
    print "Title: "
    title = gets.chomp
    { title: title, completed: false }
  end

  def create_board
    board_hash = board_form
    @store.add_board(board_hash)
  end

  def show_board(id)
    board = @store.find_board(id)
    if board.nil?
      puts "Invalid ID"
      return
    end
    lists = board.lists

    action = ""
    
    until action == "back"
      lists.each do |list|
        print_table(
          list: list.cards,
          title: "#{list.name}",
          headings: ["ID", "Title", "Members", "Labels", "Due Date", "Checklist"]
        )
      end

      action, id, extra = show_menu(
        ["create-list", "update-list LISTNAME", "delete-list LISTNAME"],
        ["create-card", "checklist ID", "update-card ID", "delete-card ID"]
      )
      case action
      when "create-list" then create_list
      when "update-list" then update_list(id, board)
      when "delete-list" then delete_list(id, board)
      when "checklist" then show_checklist(id, lists)
      when "create-card" then create_card(lists)
      when "update-card" then update_card(id, lists)
      when "delete-card" then delete_card(id, lists)
      when "back" then break 
      else
        puts "Invalid action"
      end
    end
  end

  # Methods to board 
  def update_board(id)
    new_board_hash = board_form
    @store.update_board(id, new_board_hash)
  end

  def delete_board(id)
    @store.delete_board(id)
  end

  def show_checklist(id, lists)
    card = @store.find_card(id, lists)
    if card.nil?
      puts "Invalid ID"
      return
    end
    print_checklist(card)
    sub_loop(card)
  end

  def sub_loop(card)
    action = ""
    until action == "back"
      action, id = menu("Checklist options: ", ["add", "toggle INDEX", "delete INDEX"], "back")
      case action
      when "add" then add_check_item(card)
      when "toggle" then toggle_check_item(id, card)
      when "delete" then delete_check_item(id, card)
      when "back"
        
      else
        puts "Invalid action"
      end
    return action
    end
  end

  def print_checklist(card)
    print "Card: #{card.title}\n"
    card.checklist.each_with_index do |list, index|
      if list[:completed] == true
        puts "[x] #{index + 1}. #{list[:title]}"
      else
        puts "[ ] #{index + 1}. #{list[:title]}"
      end
    end
    print "#{'-' * 37}\n"
  end

  def add_check_item(card)
    new_check_item = check_item_form
    @store.add_check_item(card, new_check_item)
    print_checklist(card)
    sub_loop(card)
  end

  def toggle_check_item(id, card)
    @store.toggle_check_item(id, card)
    print_checklist(card)
    sub_loop(card)
  end

  def delete_check_item(id, card)
    @store.delete_check_item(id, card)
    print_checklist(card)
    sub_loop(card)
  end

  def create_list
    list_hash = list_form
    @store.add_list(list_hash)
  end

  def update_list(name, board)
    new_list_hash = list_form
    @store.update_list(name, board, new_list_hash)
  end

  def delete_list(name, board)
    @store.delete_list(name, board)
  end

  def create_card(lists)
    puts "Select a list: "
    lists.each do |list|
      if list == lists.last
        print list.name + "\n"
      else
        print list.name + " | "
      end
    end
    print "> "
    name = gets.chomp
    card = card_form
    @store.add_card(lists, name, card)
  end

  def update_card(id, lists)
    card = @store.find_card(id, lists)
    if card.nil?
      puts "Invalid ID"
      return
    end

    list = lists.find { |list| list.cards.include?(card) }
    
    puts "Select a list: "
    lists.each do |list|
      if list == lists.last
        print list.name + "\n"
      else
        print list.name + " | "
      end
    end
    print "> "
    name = gets.chomp

    new_card = card_form

    if list.name == name
      @store.update_card(list, new_card, id)
    else
      @store.delete_card(id, lists)
      @store.add_card(lists, name, new_card)
    end
  end

  def delete_card(id, lists)
    @store.delete_card(id, lists)
  end
end
