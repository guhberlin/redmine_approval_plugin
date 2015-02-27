# require 'rexml/document'

module ApprovalsHelper

  def approve_button(project, changeset)
    rev = changeset.respond_to?(:identifier) ? changeset.identifier : changeset
    button_to(
      l(:button_approve),
      { :controller => "approvals", :action => "approve", :id => project, :repository_id => changeset.repository, :rev => rev},
      :confirm => l(:approve_confirmation),
      :method => :post,
      :remote => true
    )
  end

end
