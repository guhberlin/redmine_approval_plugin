class ApprovalsController < ApplicationController
  include ApprovalsHelper
  include ApplicationHelper

  before_filter :find_project,                :only => [:approve]
  before_filter :find_repository_changeset,   :only => [:approve]
  before_filter :authorize,                   :only => [:approve]
  before_filter :authorize_global,            :only => [:activate]
  accept_api_auth :approve
  unloadable


  # Sets approved status as svn revision property
  def approve
    logger.info("in approvals controller: approve")

    logger.info("in approvals controller: approve?")
    if @changeset.approved?
      logger.info("in approvals controller: approve? yep!")
      flash[:notice] = l(:approved_already)
    else
      logger.info("in approvals controller: approve? nope!")
      begin
        @changeset.approve(User.current)

        logger.info("User #{User.current.login} approved revision ##{@changeset.revision} in repository #{@changeset.repository.url}")
        flash[:notice] = l(:revision_approved, :rev => "#{@changeset.revision}")

      rescue => e
        flash[:error] = e.message
      end
    end

    respond_to do |format|
      format.html { redirect_to request.referer || '/' }
      format.js
      format.api
    end
  end


  # Activates the approval_plugin module for all projects with svn repositories
  def activate
    session[:return_to] = request.referer

    Project.all.each do |project|
      if project.module_enabled?(:repository) && project.repositories.all? {|repo| repo.class == Repository::Subversion}
        project.enable_module!(:approval_plugin) unless project.module_enabled?(:approval_plugin)
        flash[:notice] = l(:activate_approval_modules_success)
      end
    end

    respond_to do |format|
      format.html { redirect_to session[:return_to] || '/' }
      format.js
    end
  end




  private
  def find_repository_changeset
    if params[:repository_id].present?
      @repository = @project.repositories.find_by_identifier_param(params[:repository_id])
    else
      @repository = @project.repository
    end
    raise ActiveRecord::RecordNotFound if @repository.nil?

    rev = params[:rev].blank? ? @repository.default_branch : params[:rev].to_s.strip
    @changeset = @repository.find_changeset_by_name(rev)
    raise ActiveRecord::RecordNotFound if @changeset.nil?
  rescue ActiveRecord::RecordNotFound
    render_404
  end


end
