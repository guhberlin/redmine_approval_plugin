# require 'rexml/document'

module ApprovalsHelper
  # include REXML


  # Returns an array of approved revisions
  # key = revision / value = "login - timestamp"
  # def get_approved_revisions(repository, rev_from='HEAD', rev_to=rev_from)
  #   repository.scm.rev_properties("approved", rev_from, rev_to)
  # end

  # def changeset_approved?(changeset)
  #   !get_approved_revisions(changeset.repository, changeset.revision).empty?
  # end


  # Converts the "login - timestamp" string to a hash.
  # :name => login or username / date => formatted timestamp
  # def convert_approved_info(value)
  #   login = value.rpartition(" - ").first
  #   time = value.rpartition(" - ").last

  #   name = User.find_by_login(login).try(:name) || login

  #   begin
  #     date = format_time(Time.parse time)
  #   rescue
  #     date = time
  #   end

  #   return { :name => name, :date => date }
  # end


  # def init_approved_revisions(repository, first_rev, last_rev)
  #   # @approved_revisions = get_approved_revisions(repository, first_rev, last_rev)
  #   @approved_revisions = repository.scm.rev_properties("approved", first_rev, last_rev)
  # end

end
