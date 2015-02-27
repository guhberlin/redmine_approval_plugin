# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

post 'approvals/activate' , :to => 'approvals#activate'


post 'projects/:id/repository/:repository_id/revisions/:rev/approve', :to => 'approvals#approve'
post 'projects/:id/repository/revisions/:rev/approve', :to => 'approvals#approve'
