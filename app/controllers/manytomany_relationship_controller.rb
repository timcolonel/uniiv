class ManytomanyRelationshipController < ApplicationController
  include ManytomanyRelationshipHelper

  before_action :setup

  def setup
    @mparams = {}
    @mparams[:model] = params[:model]
    @mparams[:model_id] = params[:model_id]
    @mparams[:relation] = params[:relation]

    @relation = get_relation(@mparams)
  end

  def show

  end

  def list
    render :partial => 'manytomany_relationship/list', :layout => false, :locals => {:list => @relation[:list], :mparams=> @mparams}
  end

  def create
    element = @relation[:relation_class].find(params[:element_id])
    @relation[:list] << element
    #Save both for indexing
    @relation[:object].save
    element.save
    if request.xhr?
      return_json('Element added')
    else
      redirect_to :back
    end
  end

  def search_autocomplete
    relation = @relation
    result = relation[:relation_class].search do
      fulltext params[:q]
      puts 'r: ' + @relation.to_s
      without('program_group_ids', relation[:object].id)
      paginate :page => 1, :per_page => 5
    end.results
    json = {}
    json[:query] = params[:q]
    suggestions = []
    json[:suggestions] = suggestions
    result.each do |element|
      suggestion = {}
      suggestion[:value] = element.to_s
      suggestion[:data] = element.id
      suggestions << suggestion
    end
    render :json => json.to_json
  end

  def delete
    element = @relation[:relation_class].find(params[:id])
    if element.nil?
    else
      @relation[:list].destroy(element)
      element.index
      if request.xhr?
        return_json('Element removed')
      else
        _redirect_to :back
      end
    end
  end

  #Return the relation show

end
