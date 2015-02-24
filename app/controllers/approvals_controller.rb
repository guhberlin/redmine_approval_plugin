class ApprovalsController < ApplicationController
  include ApprovalsHelper
  include ApplicationHelper

  before_filter :find_project_by_project_id,  :only => [:approve]
  before_filter :authorize,                   :only => [:approve]
  before_filter :authorize_global,            :only => [:activate]
  unloadable


  # Sets approved status as svn revision property
  def approve
    logger.info("in approvals controller: approve")
    if Changeset.exists?(:id => params[:changeset_id])
      @changeset = Changeset.find_by_id(params[:changeset_id])
      # @project = @changeset.project
    else
      logger.info(l(:approve_params_error))
      flash[:error] = l(:approve_params_error)
      return
    end

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

end
