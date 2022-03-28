# frozen_string_literal: true

class PostQuery
  class AST
    extend Memoist

    attr_reader :type, :args
    delegate :all?, :none?, :and?, :or?, :not?, :opt?, :tag?, :metatag?, :wildcard?, to: :inquirer

    def initialize(type, args)
      @type = type
      @args = args
    end

    concerning :SimplificationMethods do
      def simplify
        old_ast = nil
        new_ast = rewrite_opts

        until new_ast == old_ast
          old_ast = new_ast
          new_ast = old_ast.simplify_once
        end

        new_ast
      end

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

      def rewrite_opts
        case type
        # ... ~A ~B ... = ... (or A B) ...
        # ... ~A ... = ... (or A) ... = ... A ...
        in :and | :or | :not | :opt if args.any?(&:opt?)
          opts, rest = args.partition(&:opt?)
          n = node(:or, *opts.flat_map(&:args))
          node(type, n.rewrite_opts, *rest.map(&:rewrite_opts))
        in :and | :or | :not | :opt
          node(type, *args.map(&:rewrite_opts))
        else
          self
        end
      end

      def node(type, *args)
        AST.new(type, args.sort)
      end
    end

    concerning :OutputMethods do
      def inspect
        to_sexp
      end

      def to_sexp
        case self
        in [:all]
          "all"
        in [:none]
          "none"
        in [:tag, name]
          name
        in [:metatag, name, value]
          "#{name}:#{value}"
        in [:wildcard, name]
          "(wildcard #{name})"
        in [type, *args]
          "(#{type} #{args.map(&:to_sexp).join(" ")})"
        end
      end

      def to_infix
        case self
        in [:all]
          "all"
        in [:none]
          "none"
        in [:wildcard, name]
          name
        in [:tag, name]
          name
        in [:metatag, name, value]
          "#{name}:#{value}"
        in [:not, a]
          "-#{a.to_infix}"
        in [:opt, a]
          "~#{a.to_infix}"
        in [:and, a]
          a.to_infix
        in [:or, a]
          a.to_infix
        in [:and, *a]
          "(#{a.map(&:to_infix).join(" ")})"
        in [:or, *a]
          "(#{a.map(&:to_infix).join(" or ")})"
        end
      end

      def to_a
        if term?
          [type, *args]
        else
          [type, *args.map(&:to_a)]
        end
      end
    end

    concerning :UtilityMethods do
      def each(&block)
        return enum_for(:each) unless block_given?

        case type
        in :tag | :metatag | :wildcard
          yield self
        else
          results = args.map { _1.each(&block) }
          yield self, *results
        end

        self
      end

      def nodes
        each.map { _1 }
      end

      def tag_names
        nodes.select(&:tag?).map { _1.args.first }.uniq.sort
      end

      def term?
        type.in?(%i[tag metatag wildcard all none])
      end

      def is_empty_search?
        none?
      end

      def is_single_tag?
        tag?
      end

      def is_metatag?(name)
        metatag? && args.first == name
      end

      def ==(other)
        self.class == other.class && deconstruct == other.deconstruct
      end

      def <=>(other)
        return nil unless other.is_a?(AST)
        deconstruct <=> other.deconstruct
      end

      def deconstruct
        [type, *args]
      end

      def inquirer
        ActiveSupport::StringInquirer.new(type.to_s)
      end
    end

    memoize :simplify, :simplify_once, :rewrite_opts, :inquirer, :deconstruct, :inspect, :to_sexp, :to_infix, :to_a
  end
end
