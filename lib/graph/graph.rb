module Graph
  class Graph
    attr_accessor :nodes, :edges, :position, :dimension, :subgraphs, :type, :clazz, :label, :level, :id

    def initialize (name ='', position = Point.new, dimension = Point.new, nodes = [], edges = [])
      @position = position
      @dimension = dimension
      @name = name
      @subgraphs = []
      @edges = edges
      @nodes = nodes
      @type = 'cluster'
      @clazz = ''
      @label = {:text => ''}
      @level = 0
      @id = ''
    end

    def add_graph(g)
      @subgraphs << g
      g
    end

    def self.from_dot(dot_graph, nodes, level = 0, next_content = false)
      rect = dot_graph[:bb].to_ruby

      g_pos = Point::pos_from_array(rect)
      dimension = Point::dim_from_array(rect)


      g = Graph.new('', g_pos, dimension)

      id = dot_graph[:id]
      g.id = id.source unless id.nil?

      g.level = level

      dot_graph.each_node do |node_id, node|
        state = nodes[node_id][:state]
        n = Node::from_graphviz_node(node_id, node, g, state)
        g.nodes << n
      end

      dot_graph.each_edge do |edge|
        spline = Spline::from_dot(edge) - g.position
        g.edges << spline
      end

      dot_graph.each_graph do |dot_subgraph_id, dot_subgraph|
        sub_g = Graph::from_dot(dot_subgraph, nodes)
        sub_g.position -= g.position
        g.add_graph(sub_g)
        sub_g.type = 'group_content' if next_content
        #sub_g.label = ''
      end

      #Load the label
      unless dot_graph[:label].nil?
        position = Point.pos_from_string(dot_graph[:lp].source) - g.position
        g.label = {:text => dot_graph[:label].source, :pos => Point.new(-1, position.y)}
      end
      g
    end

    def add_padding(padding)
      point = Point.new(padding, padding)
      move_nodes(point)
      move_edges(point)
      @subgraphs.each do |subgraph|
        subgraph.position += point
      end
      @dimension += point * 2
    end

    def move(point)
      move_nodes(point)
      move_edges(point)
      @subgraphs.each do |subgraph|
        subgraph.position += point
      end
    end

    def move_nodes(point)
      @nodes.each do |node|
        node.position += point
      end
    end

    def move_edges(point)
      @edges.each do |edge|
        edge += point
      end
    end
  end
end