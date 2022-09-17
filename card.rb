require "json"

class Card
  attr_accessor :title, :id, :members, :labels, :due_date, :checklist, :id_count
  @@id_count = 0
  def initialize(title:, id: nil, members: [], labels: [], due_date:, checklist: [])
    @title = title
    @id = id || (@@id_count + 1)
    @@id_count = @id
    @members = members
    @labels = labels
    @due_date = due_date
    @checklist = checklist
  end

  def details
    [@id, @title, @members.join(", "), @labels.join(", "), @due_date, check_true(@checklist)]
  end

  def check_true(checklist)
    return "0/0" if checklist.empty?
    size = checklist.size
    completed = 0
    checklist.each do |task|
      if task[:completed] == true
        completed += 1
      end
    end
    "#{completed}/#{size}"
  end

  def to_json(_arg)
    { id: @id, title: @title, members: @members, labels: @labels, due_date: @due_date, checklist: @checklist }.to_json
  end

  def update(title:, members:, labels:, due_date:)
    @title = title unless title.empty?
    @members = members unless members.empty?
    @labels = labels unless labels.empty?
    @due_date = due_date unless due_date.empty?
  end

end