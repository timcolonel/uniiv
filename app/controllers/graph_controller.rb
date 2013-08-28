require 'graph/node'
require 'graph/spline'
require 'graph/graph'
require 'graph/dot_graph'
require 'graph/packer'


class GraphController < ApplicationController
  include GraphHelper

  def show
    authorize! :read, :graph

    #current_user ||= User.new
    if current_user.university.nil?
      redirect_to user_education_path, :alert => t("university.notselected")
    elsif current_scenario.programs.size == 0
      redirect_to user_education_path, :alert => t("programs.zero.selected")
    end
  end

  def user_data
    graphs_json = []


    style = JSON.parse(open("#{Rails.root}/app/assets/test/test.json").read)

    current_scenario.programs.each do |program|
      prg_graph = get_program_graph(program, style)
      graphs_json << prg_graph
    end

    json = {}

    json[:style] = style
    json[:graphs] = graphs_json

    render :json => json.to_json
  end

  def show_program_graph
    @program = Program.find(params[:id])
  end

  def program_graph_data
    program = Program.find(params[:id])
    style = JSON.parse(open("#{Rails.root}/app/assets/test/test.json").read)
    prg_graph = get_program_graph(program, style)


    json = {}
    json[:style] = style
    json[:graphs] = [prg_graph]
    render :json => json.to_json
  end

  def get_program_graph(program, style = {})
    nodes = {}
    margin = style[:margin]
    padding = style[:padding]
    margin ||= 30
    padding ||= 15

    prg_graph = Graph.new(program.name)
    program.groups.each do |group|
      dot_graph = generate_graph_from_group(group, style)
      puts '------------------------------------'
      puts dot_graph.output
      nodes = nodes.merge(dot_graph.nodes)
      graph = generate_graph_from_dot(dot_graph.output, nodes, group.get_requirement_level)
      unless graph.dimension.x == 0 and graph.dimension.y == 0
        graph.type = 'group'
        graph.add_padding(padding)
        graph.id = group.id_to_s
        prg_graph.subgraphs << graph
      end
    end
    p = Packer.new
    prg_graph.type = 'program'
    p.pack_graph(prg_graph, margin)
    prg_graph.add_padding(padding)
    prg_graph.move(Point.new(0, padding))
    prg_graph.dimension.y += padding
    prg_graph.id = program.id_to_s
    prg_graph.label = program.name
    prg_graph
  end

  def generate_graph_from_group(group, style)
    margin = 20
    margin = style[:padding] unless style[:padding].nil?
    completed_percent = (group.get_completion_ratio(current_user) * 100).round
    label = "#{group.name} (#{completed_percent}%)"
    g = GraphViz.new(:G, :type => :digraph, :strict => true, :label => label, :fontsize => 20)
    dot_graph = DotGraph.new(g, current_user)
    content_graph = g.add_graph('cluster_' + group.name)
    content_graph[:label] = ''
    content_graph[:margin] = margin
    dot_graph.load_from_group(group, content_graph)

    dot_graph
  end

  def generate_graph_from_dot(dot, nodes, level = 0)
    json = {}
    GraphViz.parse_string(dot) do |g|
      json = Graph::from_dot(g, nodes, level, true)
    end
    json
  end

end
