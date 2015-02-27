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

# RepositoriesHelper.send(:include, ApprovalsHelper)

require 'changeset_patch'
require 'revision_patch'
require 'settings_helper_patch'
require 'subversion_adapter_patch'
require 'subversion_patch'
require 'user_patch'



ActionDispatch::Callbacks.to_prepare do
  Repository::Subversion.send(:include, SubversionPatch)
  Redmine::Scm::Adapters::SubversionAdapter.send(:include, SubversionAdapterPatch)
  Redmine::Scm::Adapters::Revision.send(:include, RevisionAdapterPatch)
  RepositoriesHelper.send(:include, ApprovalsHelper)
  RepositoriesController.send(:include, RepositoriesControllerPatch)

  User.send(:include, UserPatch)

  SettingsHelper.send(:include, SettingsHelperPatch)

  Changeset.send(:include, ChangesetPatch)
  Changeset.send(:include, ApprovalsHelper)
end
