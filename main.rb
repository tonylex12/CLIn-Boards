require_relative "clin_boards"

filename = ARGV.shift || "store.json"

print "#{'#' * 36}\n"
print "##{' ' * 6}Welcome to CLIn Boards#{' ' * 6}#\n"
print "#{'#' * 36}\n"

app = ClinBoards.new(filename)
app.start