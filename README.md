= Approval Plugin

This Plugin adds the two-man rule to SVN repositories. It allows user to approve of specific SVN revisions.

== Features

* uses SVN revision properties to store the approved status
* shows approved status of revisions in the repository
* highlighting of unapproved revisions
  
== Installation

1. Copy the folder into your plugins folder in the redmine installation.
   (make sure the plugin is installed to +plugins/approval_plugin+)
   Because this plugin does not use its own databasetables it is not necessary to perform a migration.
2. Restart your Redmine web servers.
3. Login and configure the plugin (Administration > Plugins > Configure)
4. Activate the "approval plugin" module for projects in the Project Settings => Modules. (or for all Projects in the plugin configuration)
5. Prepare the SVN repositories:
   In order to make this plugin work you have to add/edit the +PATH TO REPOSITORY/hooks/pre-revprop-change+ file
   Simply add the line +if [ "$ACTION" = "A" -a "$PROPNAME" = "approved" ]; then exit 0; fi+
   
== Uninstalling

1. delete the +approval_plugin+ folder
2. change the +pre-revprop-change+ file
Please note that the information is stored within svn revisin properties, so this information is still there once the plugin is uninstalled!


== Configuration

= Permissions
To approve revisions users have to have permission.
Settings => 'Roles and permissions' Set the permission to approve for each role. (administrators always have permission)

= Plugin configuration
Allow approval of own revisions. This allows the author of this revision to approve it himself.
Approve only if preceding revisions are already approved. If checked user can only approve revisions if previous revisions are approved.
The number indicates how big the gap to the last approved revision can be. e.g.: max gap = 5 => revision 25 can be approved if revision 19 or higher is already approved.
Highlighting unapproved revisions. Defines the color in which the message "unapproved revision" will be highlighted in.

Activate Approval Plugin module for all projects. By clicking this link the Plugin module will be activated for all projects with svn repositories.