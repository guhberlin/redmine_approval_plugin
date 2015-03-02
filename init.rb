require 'redmine'

Redmine::Plugin.register :approval_plugin do
  name 'Approval Plugin'
  author 'Alexander Lipinski'
  description 'This plugin adds an approval function for SVN revisions'
  version '0.1.0'
  author_url 'http://www.bancos.com'


  project_module :approval_plugin do
    permission :to_approve, :approvals => :approve
  end

  settings :partial => 'settings/approve_settings',
           :default => {  "unapproved_color" => "#FF0000",
                          "allow_self_approve" => nil,
                          "disallow_approve_pred_unapproved" => nil,
                          "allow_approve_pred_unapproved_gap" => "0" }


end

SettingsHelper.send(:include, SettingsHelperPatch)
RepositoriesHelper.send(:include, ApprovalsHelper)

ActionDispatch::Callbacks.to_prepare do
  Redmine::Scm::Adapters::Revision.send(:include, RevisionPatch)

  Repository::Subversion.send(:include, SubversionPatch)
  Redmine::Scm::Adapters::SubversionAdapter.send(:include, SubversionAdapterPatch)

  RepositoriesController.send(:include, RepositoriesControllerPatch)

  User.send(:include, UserPatch)

  Changeset.send(:include, ChangesetPatch)
end
