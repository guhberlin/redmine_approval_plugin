
module RepositoryPatch

  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    base.class_eval do
    end
  end

  module ClassMethods
  end

  module InstanceMethods

    def bulk_refresh_changesets(identifier_from=nil, limit=10)
      return
    end

  end
end
