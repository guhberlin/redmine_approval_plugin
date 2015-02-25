require_dependency 'pp'

module ChangesetPatch

  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    base.class_eval do
      has_one :approval
    end
  end

  module ClassMethods
  end

  module InstanceMethods

    def approved?
      return !approval.nil?
    end

    def approvable?
      logger.info("--------------------------------------------------------------------------")
      logger.info( "valid?" )


      tmp = Approval.new(
        :changeset_id => id,
        :approved_by => User.current.login,
        :revprop_already_exists => true
      )

      logger.info(tmp.valid?)
      logger.info(tmp.errors.any?)
      logger.info(tmp.errors.pretty_inspect)
      logger.info("--------------------------------------------------------------------------")

      @approve_errors = tmp.errors
      !@approve_errors.any?
    end
    def get_approve_errors
      @approve_errors
    end


    def approver
      approval.approver
    end
    def approve_date
      format_date approval.approve_date
    end

    def approve(user)
      approval = Approval.new(
        :changeset_id => id,
        :approved_by => user.login
      )

      if approval.valid?
        approval.save
      else
        @approve_errors = approval.errors
        raise l(:error_approve)
      end
    end

    def approve_from_revprop(propval)
      Approval.create_from_revprop(id, propval)
    end

  end
end

# Changeset.send(:include, ChangesetPatch)
# Changeset.send(:include, ApprovalsHelper)
