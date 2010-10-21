#
#  jQuery Selector Assertions (modifications to the prototype/scriptaculous assertions)
#
#   From http://pastie.org/303776
#
# 1. Make sure to use '#' prefix when referring to element IDs in assert_select_rjs(),
#    like this:
#            assert_select_rjs :replace_html, '#someid'
#    instead of prototype convention:
#             assert_select_rjs :replace_html, 'someid' 
#
# We monkey-patch some RJS-matching constants for assert_select_rjs to work 
# with jQuery-based code as opposed to Prototype's:
#
#
module JRails
  module SelectorAssertions
    def self.included(base)
      self.constants.each do |cnst|
        if base.const_defined? cnst
          base.send(:remove_const,cnst)
        end
      end
    end

    silence_warnings do
      RJS_PATTERN_HTML  = "\"((\\\\\"|[^\"])*)\""
      RJS_ANY_ID        = "[\"']([^\"])*[\"']"

      RJS_STATEMENTS   = {
        :chained_replace      => "\(jQuery|$\)\\(#{RJS_ANY_ID}\\)\\.replaceWith\\(#{RJS_PATTERN_HTML}\\)",
        :chained_replace_html => "\(jQuery|$\)\\(#{RJS_ANY_ID}\\)\\.updateWith\\(#{RJS_PATTERN_HTML}\\)",
        :replace_html         => "\(jQuery|$\)\\(#{RJS_ANY_ID}\\)\\.html\\(#{RJS_PATTERN_HTML}\\)",
        :replace              => "\(jQuery|$\)\\(#{RJS_ANY_ID}\\)\\.replaceWith\\(#{RJS_PATTERN_HTML}\\)",
        :insert_top           => "\(jQuery|$\)\\(#{RJS_ANY_ID}\\)\\.prepend\\(#{RJS_PATTERN_HTML}\\)",
        :insert_bottom        => "\(jQuery|$\)\\(#{RJS_ANY_ID}\\)\\.append\\(#{RJS_PATTERN_HTML}\\)",
        :effect               => "\(jQuery|$\)\\(#{RJS_ANY_ID}\\)\\.effect\\(",
        :highlight            => "\(jQuery|$\)\\(#{RJS_ANY_ID}\\)\\.effect\\('highlight'"
      }

      [:remove, :show, :hide, :toggle, :reset ].each do |action|
        RJS_STATEMENTS[action] = "\(jQuery|$\)\\(#{RJS_ANY_ID}\\)\\.#{action}\\(\\)"
      end

      RJS_STATEMENTS[:any] = Regexp.new("(#{RJS_STATEMENTS.values.join('|')})")
      RJS_PATTERN_UNICODE_ESCAPED_CHAR = /\\u([0-9a-zA-Z]{4})/
    end
  end
end

if (defined? ActionController::Assertions) 
  module ActionController::Assertions::SelectorAssertions
    include JRails::SelectorAssertions
  end
else
  module ActionDispatch::Assertions::SelectorAssertions
    include JRails::SelectorAssertions
  end
end

