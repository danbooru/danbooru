require 'cgi'
require 'uri'

%%{
  machine nested;

  #word = graph+ >{a = p; puts "entering word"} %{b = p; puts "finishing word"};
  word_with_colon = graph+ >{a = p; puts "entering colon"} %{b = p; puts "finishing colon"} :>> ':'?;

  main := |*
    'a' => {
      puts "1"
    };

    any => {
      puts data[p]
    };
  *|;
}%%

class Nested
  %% write data;

  def self.parse(s)
    stack = []

    data = s
    eof = data.length
    %% write init;
    %% write exec;
  end
end

Nested.parse('abc')