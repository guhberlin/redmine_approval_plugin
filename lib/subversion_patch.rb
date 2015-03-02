
module SubversionPatch

  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    base.class_eval do
      alias_method_chain :fetch_changesets, :approvals
      alias_method_chain :clear_changesets, :approvals
    end
  end

  module ClassMethods
  end

  module InstanceMethods

    def bulk_refresh_changesets(identifier_from=nil, limit=10)
      identifier_from ||= latest_changeset.revision.to_i - (limit - 1)

      revisions = scm.revisions('', identifier_from, identifier_from + (limit - 1))
      changesets_queue = Hash[ changesets.
        includes(:approval).
        limit(limit).
        offset(identifier_from-1).
        reverse_order.
        map { |changeset| [changeset.revision, changeset]}
      ]

      revisions.reverse_each do |revision|
        changeset = changesets_queue[revision.identifier]
        if !changeset.approved? && !revision.properties[ Approval::PROP_NAME.to_sym ].nil?
          changeset.approve_from_revprop( revision.properties[ Approval::PROP_NAME.to_sym ] )
        end
      end
    end

    def fetch_changesets_with_approvals
      scm_info = scm.info
      if scm_info
        # latest revision found in database
        db_revision = latest_changeset ? latest_changeset.revision.to_i : 0
        # latest revision in the repository
        scm_revision = scm_info.lastrev.identifier.to_i
        if db_revision < scm_revision
          logger.debug "Fetching changesets for repository #{url}" if logger && logger.debug?
          identifier_from = db_revision + 1
          while (identifier_from <= scm_revision)
            # loads changesets by batches of 200
            identifier_to = [identifier_from + 199, scm_revision].min
            revisions = scm.revisions('', identifier_to, identifier_from, :with_paths => true)
            revisions.reverse_each do |revision|
              transaction do
                changeset = Changeset.create(:repository   => self,
                                             :revision     => revision.identifier,
                                             :committer    => revision.author,
                                             :committed_on => revision.time,
                                             :comments     => revision.message)
                if !revision.properties[ Approval::PROP_NAME.to_sym ].nil?
                  changeset.approve_from_revprop( revision.properties[ Approval::PROP_NAME.to_sym ] )
                end

                revision.paths.each do |change|
                  changeset.create_change(change)
                end unless changeset.new_record?
              end
            end unless revisions.nil?
            identifier_from = identifier_to + 1
          end
        end
      end
    end

    def clear_changesets_with_approvals
      cs = Changeset.table_name
      ap = Approval.table_name

      connection.delete("DELETE FROM #{ap} WHERE #{ap}.changeset_id IN (SELECT #{cs}.id FROM #{cs} WHERE #{cs}.repository_id = #{id})")

      clear_changesets_without_approvals
    end
  end
end
