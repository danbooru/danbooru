Dir["/dev_exclusions/dtext_bench/forum_posts/*.txt"].slice(0, 100).each do |file|
  input = File.read(file)
  o1 = DTextRagel.parse(input)
  o2 = DTextRuby.parse(input).gsub(/\r/, "")
  if o1.size != o2.size
    puts input
    puts "---"
    puts o1
    puts "~~~"
    puts o2
    puts "==="
  end
end
