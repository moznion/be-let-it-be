# frozen_string_literal: true

require "parser/current"

module BeLetItBe
  class Analyzer
    def initialize(file)
      @ast = Parser::CurrentRuby.parse(File.read(file))
    end

    def find_lets
      traverse(@ast, [])
    end

    private

    def traverse(node, lets)
      # FIXME: lets should be immutable
      return lets unless node.is_a?(Parser::AST::Node)

      let_info = extract_let_info(node)
      lets << let_info unless let_info.nil?

      node.children.each do |child|
        traverse(child, lets) if child.is_a?(Parser::AST::Node)
      end

      lets
    end

    def extract_let_info(node)
      return nil unless node.type == :send
      return nil unless node.children[0].nil?

      method_name = node.children[1]
      return nil unless %i[let let!].include?(method_name)

      args = node.children[2]
      let_name = args.children[0]
      return nil unless args && args.type == :sym

      line = node.location.line

      {type: method_name, name: let_name, line:, node:}
    end
  end
end
