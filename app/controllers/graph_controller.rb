require 'graph/node'

class GraphController < ApplicationController
  include GraphHelper

  def index
    group = ProgramGroup.find(params[:id])

    output = generate_graph_from_group(group)
    @result = generate_json_from_dot(output)
  end


  def generate_graph_from_group(group)
    g = GraphViz.new(:G, :type => :digraph, :concentrate => true, :strict => true)

    map ={}
    #Add all course and operation nodes
    group.courses.each do |course|
      course_id = 'c_' + course.id.to_s
      map[course_id] = g.add_node(course_id)
      prerequisite = course.prerequisite
      unless prerequisite.nil?
        operations = prerequisite.get_all_operations
        operations.each do |op|
          op_id = 'op_' + op.id.to_s
          map[op_id] = g.add_node(op_id)
        end
      end
    end


    group.courses.each do |course|
      prerequisite = course.prerequisite
      unless prerequisite.nil?
        edges = prerequisite.get_all_edges(course)
        edges.each do |hash|
          hash.each do |k, v|
            node1 = map[k]
            node2 = map[v]
            g.add_edge(node1, node2)
          end
        end
      end
    end


    # Create two nodes

    result = ''
    # Create an edge between the two nodes
    g.output(:dot => String)

  end

  def generate_json_from_dot(dot)
    json = {}
    nodes = []
    json['nodes'] = nodes

    GraphViz.parse_string(dot) do |g|
      g.each_node do |node_id, node|
        label = node[:label]
        position = node[:pos]
        nodes << Node::from_graphviz_node(node_id, node)
      end
    end

    json.to_json
  end

end
