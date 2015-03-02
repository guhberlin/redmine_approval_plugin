
module RepositoriesControllerPatch

  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    base.class_eval do
      alias_method_chain :show, :changesets_refresh
      alias_method_chain :revisions, :changesets_refresh
      alias_method_chain :revision, :changesets_refresh
    end
  end

  module ClassMethods
  end

  module InstanceMethods
    def show_with_changesets_refresh
      @repository.bulk_refresh_changesets

      show_without_changesets_refresh
    end

    def revisions_with_changesets_refresh
      changeset_count = @repository.changesets.count
      changeset_pages = Redmine::Pagination::Paginator.new(
        changeset_count,
        per_page_option,
        params['page']
      )
      limit = changeset_count < changeset_pages.per_page ? changeset_count : changeset_pages.per_page

      @repository.bulk_refresh_changesets(changeset_pages.offset + 1, limit)

      revisions_without_changesets_refresh
    end

    def revision_with_changesets_refresh
      @repository.bulk_refresh_changesets(@changeset.revision.to_i, 1)

      revision_without_changesets_refresh
    end
  end
end
