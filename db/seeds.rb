# Seeds a demo board so the app has something to show on first boot.
return if Board.exists?

board = Board.create!(
  name: "Launch Tandem",
  description: "A tiny real-time kanban board built with Rails 8 and Hotwire."
)

{
  todo: [ "Write the README", "Record a demo GIF", "Add keyboard shortcuts" ],
  doing: [ "Polish dark mode", "Deploy to Render" ],
  done: [ "Turbo Streams for new cards", "Drag and drop with Stimulus", "Live sync with page refreshes" ]
}.each do |status, titles|
  titles.each { |title| board.cards.create!(title: title, status: status) }
end

Board.create!(name: "Groceries", description: "Shared list for the week.").tap do |groceries|
  %w[Oat\ milk Coffee\ beans Lemons].each { |item| groceries.cards.create!(title: item) }
end
