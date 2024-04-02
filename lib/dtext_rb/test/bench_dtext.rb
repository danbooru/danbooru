require "benchmark/ips"
require "dtext"

cheatsheet = File.read("test/files/dtext.txt")
forum = File.read("test/files/forum-229443.txt")
wiki = File.read("test/files/touhou-wiki.txt")
comment = "Neko Tama-nee is the secret guardian of Danbooru. You must please her or you will not pass, you will perish."

Benchmark.ips do |bm|
  bm.report("ragel cheatsheet") { DText.parse(cheatsheet) }
  bm.report("ruby cheatsheet") { DText::Ruby.parse(cheatsheet) }

  bm.report("ragel forum #229443") { DText.parse(forum) }
  bm.report("ruby forum #229443") { DText::Ruby.parse(forum) }

  bm.report("ragel touhou wiki") { DText.parse(wiki) }
  bm.report("ruby touhou wiki") { DText::Ruby.parse(wiki) }

  bm.report("ragel comment") { DText.parse(comment) }
  bm.report("ruby comment") { DText::Ruby.parse(comment) }

  bm.compare!
end
