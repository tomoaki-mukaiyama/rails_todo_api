20.times do
  Todo.create task: Faker::JapaneseMedia::OnePiece.character,
              description: Faker::JapaneseMedia::OnePiece.quote
end