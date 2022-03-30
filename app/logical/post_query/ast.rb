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
# The AST returned by the parser is normally simplified with `#simplify` before
# it's used. This is for several reasons:
#
# * To replace the `~` operator with `or` clauses.
# * To remove redundant `and` and `or` nodes.
# * To normalize the AST to conjunctive normal form.
#
# @example
#
#   PostQuery::AST.new(:or, [PostQuery::AST.new(:tag, "1girl"), PostQuery::AST.new(:metatag, "rating", "s")]).to_sexp
#   => "(or 1girl rating:s)"
#
#   PostQuery::Parser.parse("cat_girl or (cat_ears tail)").to_sexp
#   => "(or (and cat_girl) (and (and cat_ears tail)))"
#
#   PostQuery::Parser.parse("cat_girl or (cat_ears tail)").simplify.to_sexp
#   => "(and (or cat_ears cat_girl) (or cat_girl tail))"

class PostQuery
  class AST
    extend Memoist
    include Comparable
    include Enumerable

    attr_reader :type, :args
    delegate :all?, :none?, :and?, :or?, :not?, :opt?, :tag?, :metatag?, :wildcard?, to: :inquirer

    # Create an AST node.
    #
    # @param type [Symbol] The type of the AST node.
    # @param args [Array] The arguments for the node (either a list of child nodes for
    #   AND/OR/NOT/OPT nodes, or the name and/or value for tag, metatag, or wildcard nodes).
    def initialize(type, args)
      @type = type
      @args = args
    end

    concerning :SimplificationMethods do
      # Simplify the AST by rewriting `~` to `or` clauses, and by reducing it to
      # conjunctive normal form (that is, product-of-sums form, or an AND of ORs).
      #
      # The algorithm is to repeatedly apply the rules of Boolean algebra, one
      # at a time in a top-down fashion, until the AST can't be simplified any more.
      #
      # @return [AST] A new simplified AST
      def simplify
        old_ast = nil
        new_ast = rewrite_opts

        until new_ast == old_ast
          old_ast = new_ast
          new_ast = old_ast.simplify_once
        end

        new_ast
      end

      # Simplify the AST once by applying the rules of Boolean algebra in a single top-down pass.
      #
      # @return [AST] A new simplified AST
      def simplify_once
        case self

        # (and A) = A
        in [:and, a]
          a

        # (or A) = A
        in [:or, a]
          a

        # Double negation: -(-A) = A
        in [:not, [:not, a]]
          a

        # DeMorgan's law: -(A and B) = -A or -B
        in [:not, [:and, *args]]
          node(:or, *args.map { node(:not, _1) })

        # DeMorgan's law: -(A or B) = -A and -B
        in [:not, [:or, *args]]
          node(:and, *args.map { node(:not, _1) })

        # Associative law: (or (or A B) C) = (or A B C)
        in [:or, *args] if args.any?(&:or?)
          ors, others = args.partition(&:or?)
          node(:or, *ors.flat_map(&:args), *others)

        # Associative law: (and (and A B) C) = (and A B C)
        in [:and, *args] if args.any?(&:and?)
          ands, others = args.partition(&:and?)
          node(:and, *ands.flat_map(&:args), *others)

        # Distributive law: A or (B and C) = (A or B) and (A or C)
        # (or A (and B C ...) ... = (and (or A B ...) (or A C ...) ...
        in [:or, *args] if args.any?(&:and?)
          ands, others = args.partition(&:and?)
          first, rest = ands.first, ands[1..] + others
          node(:and, *first.args.map { node(:or, _1, *rest) })

        in [:not, arg]
          node(:not, arg.simplify_once)

        in [:and, *args]
          node(:and, *args.map(&:simplify_once))

        in [:or, *args]
          node(:or, *args.map(&:simplify_once))

        else
          self
        end
      end

      # Rewrite the `~` operator to `or` clauses.
      #
      # @return [AST] A new AST with `:opt` nodes replaced with `:or` nodes.
      def rewrite_opts
        # ... ~A ~B ... = ... (or A B) ...
        # ... ~A ... = ... (or A) ... = ... A ...
        if children.any?(&:opt?)
          opts, non_opts = children.partition(&:opt?)
          or_node = node(:or, *opts.flat_map(&:children))
          node(type, or_node, *non_opts).rewrite_opts
        elsif children.any?
          node(type, *children.map(&:rewrite_opts))
        else
          self
        end
      end

      # Create a new AST node, sorting the child nodes so that the AST is normalized to a consistent form.
      def node(type, *args)
        AST.new(type, args.sort)
      end
    end

    concerning :OutputMethods do
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
        in [:metatag, name, value]
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
        in [:metatag, name, value]
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

      # Convert the AST to a series of nested arrays.
      def to_tree
        if term?
          [type, *args]
        else
          [type, *args.map(&:to_tree)]
        end
      end
    end

    concerning :UtilityMethods do
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

      # @return [String, nil] The value of the metatag as a quoted string, if a metatag node.
      def quoted_value
        return nil unless metatag?

        if value.include?(" ") || value.starts_with?('"') || value.empty?
          %Q{"#{value.gsub(/"/, '\\"')}"}
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

    memoize :simplify, :simplify_once, :rewrite_opts, :inquirer, :deconstruct, :inspect, :to_sexp, :to_infix, :to_tree, :nodes, :tags, :metatags, :tag_names
  end
end
