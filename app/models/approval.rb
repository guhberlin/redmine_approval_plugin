

class Approval < ActiveRecord::Base
  belongs_to :changeset
  belongs_to :user

  attr_accessor :revprop_already_exists

  validates_presence_of :changeset_id, :approved_by
  validates_uniqueness_of :changeset_id
  validate :approval_with_pred_unapproved_allowed, :approver_not_equal_to_committer

  after_initialize :set_defaults
  after_save :set_rev_prop

  PROP_NAME = 'approved'

  class << self
    def create_from_revprop(changeset_id, propvalue)
      approval_info = parse_approval(propvalue)

      return self.create(
         :changeset_id => changeset_id,
         :approved_by => approval_info[:approved_by],
         :approved_on => approval_info[:approved_on],
         :revprop_already_exists => true
       )
    end

    private
      # Converts the "login - timestamp" from string to a hash.
      # { :approved_by => login , :approved_on => timestamp }
      def parse_approval(approval_string)
        return {
          :approved_by => approval_string.rpartition(" - ").first,
          :approved_on => approval_string.rpartition(" - ").last
        }
      end
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
      if !@revprop_already_exists && changeset.repository.scm_name == 'Subversion'
        changeset.repository.scm.set_rev_property(PROP_NAME, "#{approved_by} - #{approved_on}", changeset.identifier)
      end
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
