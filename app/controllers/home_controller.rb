class HomeController < ApplicationController

  before_filter :authentication_required, only: [:index_with_auth, :temp_dashboard]

  def index
    render :index
  end

  def index_with_auth
    render :index
  end

  def temp_home
    papers = Paper.published
    render 'temp_home', locals: { papers: papers }
  end

  def temp_dashboard
    reviewer_papers = current_user.papers_as_reviewer
    editor_papers = current_user.papers_as_editor
    author_papers = current_user.papers_as_submittor

    render 'temp_dashboard', locals: {  reviewer_papers: reviewer_papers,
                                        editor_papers: editor_papers,
                                        author_papers: author_papers }
  end
end
