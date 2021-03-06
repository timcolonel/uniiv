class GraphController < ApplicationController
  before_action :setup

  def setup
    @term = nil
    unless params[:semester].nil? or params[:year].nil?
      year = params[:year]
      semester = Course::Semester.find(params[:semester])
      @term = Utils::Term.new(semester, year)
    end
    @term ||= Utils::Term::now
  end

  def show
    authorize! :read, :graph

    if current_user.university.nil?
      redirect_to user_education_path, alert: t('university.notselected')
    elsif current_scenario.programs.size == 0
      redirect_to user_education_path, alert: t('program.zero.selected')
    end
    @fullwidth=true
    @footer = false
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
    @program = Program::Program.find(params[:id])
    @fullwidth=true
  end

  def program_graph_data
    program = Program::Program.find(params[:id])
    version = program.last_version
    style = JSON.parse(open("#{Rails.root}/app/assets/test/test.json").read)
    prg_graph = get_program_graph(version, style)

    json = {}
    json[:style] = style
    json[:graphs] = [prg_graph]
    render :json => json.to_json
  end

  def get_program_graph(program, style = {})
    nodes = {}
    margin = (style[:margin] || 30)
    padding = (style[:padding] || 15)

    program_graph = Graph::Graph.new(program.program.name)
    program.groups.each do |group|
      dot_graph = generate_graph_from_group(group, style)
      nodes = nodes.merge(dot_graph.nodes)
      graph = generate_graph_from_dot(dot_graph.output, nodes, group.get_requirement_level)
      unless graph.dimension.x == 0 and graph.dimension.y == 0
        graph.type = 'group'
        graph.add_padding(padding)
        graph.id = group.id_to_s
        program_graph.subgraphs << graph
      end
    end
    program_graph.type = 'program'
    p = Graph::Packer.new
    p.pack_graph(program_graph, margin)
    program_graph.add_padding(padding)
    program_graph.move(Graph::Point.new(0, padding))
    program_graph.dimension.y += padding
    program_graph.id = program.id_to_s
    program_graph.label = program.program.name
    program_graph
  end

  def generate_graph_from_group(group, style)
    margin = 20
    margin = style[:padding] unless style[:padding].nil?
    completed_percent = group.get_completion_ratio(current_scenario, @term).percent.round
    label = "#{group.name} (#{completed_percent}%)"
    g = GraphViz.new(:G, type: :digraph, strict: true, label: label, fontsize: 20)
    dot_graph = Graph::DotGraph.new(g, current_scenario, @term)
    content_graph = g.add_graph("cluster_#{group.name}")
    content_graph[:label] = ''
    content_graph[:margin] = margin
    dot_graph.load_from_group(group, content_graph)

    dot_graph
  end

  def generate_graph_from_dot(dot, nodes, level = 0)
    json = {}
    GraphViz.parse_string(dot) do |g|
      json = Graph::Graph::from_dot(g, nodes, level, true)
    end
    json
  end

end
