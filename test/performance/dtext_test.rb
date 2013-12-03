require 'test_helper'
require 'rails/performance_test_help'

class DtextTest < ActionDispatch::PerformanceTest
  self.profile_options = {
    :runs => 5
  }
  # Refer to the documentation for all available options
  # self.profile_options = { :runs => 5, :metrics => [:wall_time, :memory]
  #                          :output => 'tmp/performance', :formats => [:flat] }

  def setup
    base_text = <<-EOS
      [b]Lorem ipsum[/b] dolor sit amet, "consectetur":http://www.google.com adipisicing elit, sed do eiusmod
      tempor incididunt ut labore et [[dolore]] [[magna|MAGNA]] aliqua. Ut enim ad minim veniam,
      quis nostrud exercitation ullamco {{laboris}} nisi ut aliquip ex ea commodo
      h1. consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse
      cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
      [quote]proident, sunt in culpa qui officia deserunt mollit anim id est laborum.[/quote]

      * list of items
      ** list of items
      *** list of items
      ** list of items user #1234
      * list of items post #1234

      [spoiler]this is a spoiler[/spoiler]
    EOS
    @text = base_text * 1000
  end

  def test_parse
    DText.parse(@text)
  end
end
