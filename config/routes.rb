# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

post 'approvals/approve', :to => 'approvals#approve'
post 'approvals/activate' , :to => 'approvals#activate'
