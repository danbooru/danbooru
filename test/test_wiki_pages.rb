Dir["/dev_exclusions/dtext_bench/wiki_pages/*.txt"].sort.slice(20, 10).each do |file|
  input = File.read(file)
  o1 = DTextRagel.parse(input.dup).gsub(/\s+<\/p>/, "</p>")
  o2 = DTextRuby.parse(input.dup).gsub(/\r/, "").gsub(/\s+<\/p>/, "</p>")
  if o1.size != o2.size
    puts input
    puts "---"
    puts o1
    puts "~~~"
    puts o2
    puts "==="
  end
end
