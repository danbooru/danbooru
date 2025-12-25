# frozen_string_literal: true

# A PostQuery::AST is an abstract syntax tree representing a search parsed by
# `PostQuery::Parser#parse`. It has methods for printing, manipulating, and
# simpifying ASTs returned by the parser.
#
# There are nine AST node types:
#
# * :all (representing the search that returns everything, aka the empty search)
# * :none (representing the search that returns nothing)
# * :tag (a single tag)
# * :metatag (a metatag with a name and value)
# * :wildcard (a wildcard tag, e.g. `blue_*`)
# * :and (an n-ary AND clause)
# * :or (an n-nary OR clause)
# * :not (a unary NOT clause)
# * :opt (the unary `~`, or 'optional' operator)
#
# The AST returned by the parser is normally rewritten with `#to_cnf` before
# it's used. This is for several reasons:
#
# * To replace the `~` operator with `or` clauses.
# * To remove redundant `and` and `or` nodes.
# * To transform the AST to conjunctive normal form.
# * To sort the AST into alphabetical order.
#
# @example
#
#   PostQuery::AST.new(:or, [PostQuery::AST.new(:tag, "1girl"), PostQuery::AST.new(:metatag, "rating", "s")]).to_sexp
#   => "(or 1girl rating:s)"
#
#   PostQuery::Parser.parse("cat_girl or (cat_ears tail)").to_sexp
#   => "(or (and cat_girl) (and (and cat_ears tail)))"
#
#   PostQuery::Parser.parse("cat_girl or (cat_ears tail)").to_cnf.to_sexp
#   => "(and (or cat_ears cat_girl) (or cat_girl tail))"

class PostQuery
  class AST
    extend Memoist
    include Comparable
    include Enumerable

    attr_reader :type, :args, :parent
    protected attr_writer :parent
    delegate :all?, :none?, :and?, :or?, :not?, :opt?, :tag?, :metatag?, :wildcard?, to: :inquirer

    # Create an AST node.
    #
    # @param type [Symbol] The type of the AST node.
    # @param args [Array] The arguments for the node (either a list of child nodes for
    #   AND/OR/NOT/OPT nodes, or the name and/or value for tag, metatag, or wildcard nodes).
    def initialize(type, args)
      @type = type
      @parent = nil

      if term?
        @args = args
      else
        @args = args.deep_dup
        @args.each { _1.parent = self }
      end
    end

    concerning :ConstructorMethods do
      class_methods do
        def all
          AST.new(:all, [])
        end

        def none
          AST.new(:none, [])
        end

        def not(ast)
          AST.new(:not, [ast])
        end

        def opt(ast)
          AST.new(:opt, [ast])
        end

        def tag(name)
          AST.new(:tag, [name.downcase])
        end

        def wildcard(name)
          AST.new(:wildcard, [name.downcase])
        end

        def metatag(name, value, quoted = false)
          name = name.downcase
          name = name.singularize + "_count" if name.in?(PostQueryBuilder::COUNT_METATAG_SYNONYMS)

          if name == "order"
            attribute, direction, _tail = value.to_s.downcase.partition(/_(asc|desc)\z/i)
            if attribute.in?(PostQueryBuilder::COUNT_METATAG_SYNONYMS)
              value = attribute.singularize + "_count" + direction
            end
          end

          AST.new(:metatag, [name, value, quoted])
        end
      end

      def &(other)
        AST.new(:and, [self, other])
      end

      def |(other)
        AST.new(:or, [self, other])
      end

      def ~
        AST.new(:opt, [self])
      end

      def -@
        AST.new(:not, [self])
      end

      # Create an AST node.
      def node(type, *args)
        AST.new(type, args)
      end
    end

    concerning :SimplificationMethods do
      # Convert the AST to conjunctive normal form, that is, product-of-sums
      # form, or an AND of ORs. The result is a single top-level AND clause,
      # containing a series of tags, metatags, and OR clauses, with no deeply
      # nested subexpressions.
      #
      # @return [AST] A new AST in conjunctive normal form.
      def to_cnf
        rewrite_opts.simplify.sort
      end

      # Rewrite the `~` operator to `or` clauses.
      #
      # @return [AST] A new AST with `:opt` nodes replaced with `:or` nodes.
      def rewrite_opts
        rewrite do |ast|
          # ... ~A ~B ... = ... (or A B) ...
          # ... ~A ... = ... (or A) ... = ... A ...
          if ast.children.any?(&:opt?)
            opts, non_opts = ast.children.partition(&:opt?)
            or_node = node(:or, *opts.flat_map(&:children))
            node(ast.type, or_node, *non_opts)
          else
            ast
          end
        end
      end

      # Simplify the AST by eliminating unnecessary AND and OR nodes, and by
      # expanding out deeply nested subexpressions. The result is an AST in
      # conjunctive normal form.
      #
      # @return [AST] A new AST in conjunctive normal form.
      def simplify
        repeat_until_unchanged do |ast|
          ast.trim_once.simplify_once
        end
      end

      # Simplify the AST once in a single top-down pass by applying the double
      # negation law, DeMorgan's law, and the distributive law. This expands
      # out deeply nested subexpressions.
      #
      # @return [AST] A new simplified AST
      def simplify_once
        rewrite do |ast|
          case ast

          # Double negation: -(-A) = A
          in [:not, [:not, a]]
            a

          # DeMorgan's law: -(A and B) = -A or -B
          in [:not, [:and, *children]]
            node(:or, *children.map { node(:not, _1) })

          # DeMorgan's law: -(A or B) = -A and -B
          in [:not, [:or, *children]]
            node(:and, *children.map { node(:not, _1) })

          # Distributive law: A or (B and C) = (A or B) and (A or C)
          # (or A (and B C ...) ... = (and (or A B ...) (or A C ...) ...
          in [:or, *children] if children.any?(&:and?)
            ands, non_ands = children.partition(&:and?)
            first_and, rest = ands.first, ands[1..] + non_ands
            node(:and, *first_and.children.map { node(:or, _1, *rest) })

          else
            ast
          end
        end
      end

      # Trim the AST by eliminating redundant AND and OR clauses.
      def trim
        repeat_until_unchanged(&:trim_once)
      end

      def trim_once
        rewrite do |ast|
          case ast

          # (and A) = A; (or A) = A
          in :and | :or, a
            a

          # Associative law: (and (and A B) C) = (and A B C)
          in :and, *children
            node(:and, *children.flat_map { _1.and? ? _1.children : _1 })

          # Associative law: (or (or A B) C) = (or A B C)
          in :or, *children
            node(:or, *children.flat_map { _1.or? ? _1.children : _1 })

          else
            ast
          end
        end
      end

      # Sort the AST into alphabetical order.
      def sort
        if children.present?
          node(type, *children.map(&:sort).sort)
        else
          self
        end
      end
    end

    concerning :OutputMethods do
      def to_s
        to_infix
      end

      def inspect
        to_sexp
      end

      # Display the AST as an S-expression.
      def to_sexp
        case self
        in [:all]
          "all"
        in [:none]
          "none"
        in [:tag, name]
          name
        in [:metatag, name, value, quoted]
          "#{name}:#{quoted_value}"
        in [:wildcard, name]
          "(wildcard #{name})"
        in [type, *args]
          "(#{type} #{args.map(&:to_sexp).join(" ")})"
        end
      end

      # Display the AST in infix notation.
      def to_infix
        case self
        in [:all]
          ""
        in [:none]
          "none"
        in [:wildcard, name]
          name
        in [:tag, name]
          name
        in [:metatag, name, value, quoted]
          "#{name}:#{quoted_value}"
        in :not, child
          child.term? ? "-#{child.to_infix}" : "-(#{child.to_infix})"
        in :opt, child
          child.term? ? "~#{child.to_infix}" : "~(#{child.to_infix})"
        in :and, *children
          children.map { _1.children.many? ? "(#{_1.to_infix})" : _1.to_infix }.join(" ")
        in :or, *children
          children.map { _1.children.many? ? "(#{_1.to_infix})" : _1.to_infix }.join(" or ")
        end
      end

      # Display the search in "pretty" form, with capitalized tags.
      def to_pretty_string
        case self
        in [:all]
          ""
        in [:none]
          "none"
        in [:wildcard, name]
          name
        in [:tag, name]
          name.tr("_", " ").startcase
        in [:metatag, name, value, quoted]
          "#{name}:#{quoted_value}"
        in :not, child
          child.term? ? "-#{child.to_pretty_string}" : "-(#{child.to_pretty_string})"
        in :opt, child
          child.term? ? "~#{child.to_pretty_string}" : "~(#{child.to_pretty_string})"
        in :and, *children
          children.map { _1.children.many? ? "(#{_1.to_pretty_string})" : _1.to_pretty_string }.to_sentence
        in :or, *children
          children.map { _1.children.many? ? "(#{_1.to_pretty_string})" : _1.to_pretty_string }.to_sentence(two_words_connector: " or ", last_word_connector: ", or ")
        end
      end

      # Convert the AST to a series of nested arrays.
      def to_tree
        if term?
          [type, *args]
        else
          [type, *args.map(&:to_tree)]
        end
      end
    end

    concerning :TraversalMethods do
      # Traverse the AST in depth-first left-to-right order, calling the block on each
      # node and passing it the current node and the results from visiting each subtree.
      def visit(&block)
        return enum_for(:visit) unless block_given?

        results = children.map { _1.visit(&block) }
        yield self, *results
      end

      # Traverse the AST in depth-first left-to-right order, calling the block on each node.
      def each(&block)
        return enum_for(:each) unless block_given?
        visit { |node| yield node }
        self
      end

      # Rewrite the AST by calling the block on each node and replacing the node with the result.
      def rewrite(&block)
        ast = yield self

        if ast.children.any?
          node(ast.type, *ast.children.map { _1.rewrite(&block) } )
        else
          ast
        end
      end

      # Replace tags according to a hash mapping old tag names to new tag names.
      #
      # @param replacements [Hash<String, String>] A hash mapping old tag names to new tag names.
      # @return [AST] A new AST with the tags replaced.
      def replace_tags(replacements)
        rewrite do |node|
          if node.tag? && replacements.has_key?(node.name)
            node(:tag, replacements[node.name])
          else
            node
          end
        end
      end

      # Call the block on the AST repeatedly until the output stops changing.
      #
      # `ast.repeat_until_unchanged(&:trim)` is like doing `ast.trim.trim.trim...`
      # until the AST can't be trimmed any more.
      def repeat_until_unchanged(&block)
        old = nil
        new = self

        until new == old
          old = new
          new = yield old
        end

        new
      end
    end

    concerning :UtilityMethods do
      # @return [Array<AST>] A flat list of all the nodes in the AST, in depth-first left-to-right order.
      def nodes
        each.map
      end

      # @return [Array<AST>] A list of all unique tag nodes in the AST.
      def tags
        nodes.select(&:tag?).uniq.sort
      end

      # @return [Array<AST>] A list of all unique metatag nodes in the AST.
      def metatags
        nodes.select(&:metatag?).uniq.sort
      end

      # @return [Array<AST>] A list of all unique wildcard nodes in the AST.
      def wildcards
        nodes.select(&:wildcard?).uniq.sort
      end

      # @return [Array<String>] The names of all unique tags in the AST.
      def tag_names
        tags.map(&:name)
      end

      # @return [Array<AST>] The list of all parent nodes of this node.
      def parents
        parents = []

        node = self
        until node.parent.nil?
          parents << node.parent
          node = node.parent
        end

        parents
      end

      # True if the AST is a simple node, that is a leaf node with no child nodes.
      def term?
        type.in?(%i[tag metatag wildcard all none])
      end

      # @return [String, nil] The name of the tag, metatag, or wildcard, if one of these nodes.
      def name
        args.first if tag? || metatag? || wildcard?
      end

      # @return [String, nil] The value of the metatag, if a metatag node.
      def value
        args.second if metatag?
      end

      # @return [String, nil] True if the metatag's value was enclosed in quotes.
      def quoted?
        args.third if metatag?
      end

      # @return [String, nil] The value of the metatag as a quoted string, if a metatag node.
      def quoted_value
        return nil unless metatag?

        if quoted? || value.match?(/[[:space:]]/)
          %{"#{value.gsub('"', '\\"')}"}
        else
          value
        end
      end

      # @return [Array<AST>] The child nodes, if the node has children.
      def children
        term? ? [] : args
      end

      def <=>(other)
        return nil unless other.is_a?(AST)
        deconstruct <=> other.deconstruct
      end

      # Deconstruct the node into an array (used for pattern matching).
      def deconstruct
        [type, *args]
      end

      def inquirer
        ActiveSupport::StringInquirer.new(type.to_s)
      end
    end

    memoize :to_cnf, :simplify, :simplify_once, :rewrite_opts, :trim, :trim_once, :sort, :inquirer, :deconstruct, :inspect, :to_sexp, :to_infix, :to_pretty_string, :to_tree, :nodes, :tags, :metatags, :tag_names, :parents
  end
end
