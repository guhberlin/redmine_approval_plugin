

class Approval < ActiveRecord::Base
  belongs_to :changeset
  belongs_to :user

  attr_accessor :revprop_already_exists

  validates_presence_of :changeset_id, :approved_by
  validates_uniqueness_of :changeset_id
  validate :approval_with_pred_unapproved_allowed, :approver_not_equal_to_committer

  # before_validation :set_defaults
  after_initialize :set_defaults
  after_save :set_rev_prop

  PROP_NAME = 'approved'

  class << self

    # def changeset_approvable?(changeset)
    #   if Setting.plugin_approval_plugin['disallow_approve_pred_unapproved']
    #     allowed_gap = Setting.plugin_approval_plugin['allow_approve_pred_unapproved_gap'].to_i

    #     if allowed_gap < (changeset.revision.to_i - 1)
    #       return false if changeset.repository.get_approvals(changeset.revision, changeset.revision.to_i - allowed_gap -1).empty?
    #     end
    #   end
    #   return true
    # end

    # def changeset_approvable_by_user?(changeset, user)
    #   if user == User.find_by_login(changeset.committer)
    #     return false unless Setting.plugin_approval_plugin['allow_self_approve']
    #   end
    #   return true
    # end

    # def approve_string(user)
    #   return"#{user.login} - #{Time.now}"
    # end
  end

  def approver
    user || approved_by #.to_s.split('<').first
  end

  def approve_date
    format_time approved_on
  end



  private

    def set_defaults
      self.approved_on ||= Time.now
      self.user = User.find_by_login(approved_by)
    end

    def set_rev_prop
      if !@revprop_already_exists
        changeset.repository.scm.set_rev_property(PROP_NAME, "#{approved_by} - #{approved_on}", changeset.identifier)
      end
    end

    # Converts the "login - timestamp" string to a hash.
    # :name => login or username / date => formatted timestamp
    def parse_approval(approval_string)
      login = approval_string.rpartition(" - ").first
      time = approval_string.rpartition(" - ").last

      name = User.find_by_login(login).try(:name) || login

      begin
        date = format_time(Time.parse time)
      rescue
        date = time
      end

      return { :name => name, :date => date }
    end


    def approval_with_pred_unapproved_allowed
      if Setting.plugin_approval_plugin['disallow_approve_pred_unapproved']
        allowed_gap = Setting.plugin_approval_plugin['allow_approve_pred_unapproved_gap'].to_i() +1

        previous_changeset = changeset.nil? ? nil : changeset.previous
        allowed_gap.times do
          return if previous_changeset.nil? || previous_changeset.approved?
          previous_changeset = previous_changeset.previous
        end

        errors.add(:pred_unapproved, l(:approve_pred_info, :count => allowed_gap))
      end
    end

    def approver_not_equal_to_committer
      if !Setting.plugin_approval_plugin['allow_self_approve'] && approved_by == changeset.committer
        errors.add(:approved_by, l(:approve_self_error))
      end
    end
end
