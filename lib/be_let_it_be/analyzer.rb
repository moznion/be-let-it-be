# frozen_string_literal: true

require "prism"

module BeLetItBe
  class Analyzer
    def initialize(file)
      file_path = file.respond_to?(:path) ? file.path : file
      @ast = Prism.parse_file(file_path).value
    end

    def find_lets
      traverse(@ast, [])
    end

    private

    def traverse(node, lets)
      # FIXME: lets should be immutable
      return lets unless node.is_a?(Prism::Node)

      let_info = extract_let_info(node)
      lets << let_info unless let_info.nil?

      case node
      when Prism::ProgramNode
        traverse(node.statements, lets) if node.statements
      when Prism::StatementsNode
        node.body.each { |child| traverse(child, lets) }
      when Prism::CallNode
        traverse(node.block, lets) if node.block
      when Prism::BlockNode
        traverse(node.body, lets) if node.body
      else
        # NOP
      end

      lets
    end

    def extract_let_info(node)
      return nil unless node.is_a?(Prism::CallNode)
      return nil unless node.receiver.nil?

      method_name = node.name
      return nil unless [:let, :let!].include?(method_name)

      return nil unless node.arguments && node.arguments.arguments.length > 0

      first_arg = node.arguments.arguments[0]
      return nil unless first_arg.is_a?(Prism::SymbolNode)

      name = first_arg.value.to_sym
      line = node.location.start_line

      {type: method_name, name:, line:, node:}
    end
  end
end
