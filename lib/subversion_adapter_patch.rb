require 'open3'

module SubversionAdapterPatch

  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    base.class_eval do
      alias_method_chain :revisions, :revprops
    end
  end

  module ClassMethods
  end

  module InstanceMethods

    def revisions_with_revprops(path=nil, identifier_from=nil, identifier_to=nil, options={})
      path ||= ''
      identifier_from = (identifier_from && identifier_from.to_i > 0) ? identifier_from.to_i : "HEAD"
      identifier_to = (identifier_to && identifier_to.to_i > 0) ? identifier_to.to_i : 1
      revisions = Redmine::Scm::Adapters::Revisions.new
      cmd = "#{self.class.sq_bin} log --xml --with-all-revprops -r #{identifier_from}:#{identifier_to}"
      cmd << credentials_string
      cmd << " --verbose " if  options[:with_paths]
      cmd << " --limit #{options[:limit].to_i}" if options[:limit]
      cmd << ' ' + target(path)
      shellout(cmd) do |io|
        output = io.read
        if output.respond_to?(:force_encoding)
          output.force_encoding('UTF-8')
        end
        begin
          doc = parse_xml(output)
          each_xml_element(doc['log'], 'logentry') do |logentry|
            paths = []
            each_xml_element(logentry['paths'], 'path') do |path|
              paths << {:action => path['action'],
                        :path => path['__content__'],
                        :from_path => path['copyfrom-path'],
                        :from_revision => path['copyfrom-rev']
                        }
            end if logentry['paths'] && logentry['paths']['path']
            paths.sort! { |x,y| x[:path] <=> y[:path] }

            revprops = {}
            each_xml_element(logentry['revprops'], 'property') do |property|
              revprops[property['name'].to_sym] = property['__content__']
            end if logentry['revprops'] && logentry['revprops']['property']

            revisions << Redmine::Scm::Adapters::Revision.new({
              :identifier => logentry['revision'],
              :author => (logentry['author'] ? logentry['author']['__content__'] : ""),
              :time => Time.parse(logentry['date']['__content__'].to_s).localtime,
              :message => logentry['msg']['__content__'],
              :paths => paths,
              :properties => revprops
            })
          end
        rescue
        end
      end
      return nil if $? && $?.exitstatus != 0
      revisions
    end

    # returns array with revision as indexes, and property value as values
    def rev_properties(propname, identifier_from=nil , identifier_to=nil)
      identifier_from = (identifier_from and identifier_from.to_i > 0) ? identifier_from.to_i : "HEAD"
      identifier_to = (identifier_to and identifier_to.to_i > 0) ? identifier_to.to_i : identifier_from

      cmd = "#{self.class.sq_bin} log --xml --with-revprop #{propname} -r#{identifier_from}:#{identifier_to} #{target}"
      cmd << credentials_string

      properties = {}
      shellout(cmd) do |io|
        output = io.read
        if output.respond_to?(:force_encoding)
          output.force_encoding('UTF-8')
        end
        begin
          doc = parse_xml(output)
          each_xml_element(doc['log'], 'logentry') do |logentry|
            each_xml_element(logentry['revprops'], 'property') do |property|
              if property['name'] == propname
                properties[ logentry['revision'] ] = property['__content__'].to_s
              end
            end
          end
        rescue
        end
      end
      return nil if $? && $?.exitstatus != 0
      properties
    end

    def set_rev_property(propname, propval, identifier)
      cmd = "#{self.class.sq_bin} propset --revprop -r#{identifier} #{propname} '#{propval}' #{target}"
      cmd << credentials_string

      svnerr = []
      shellout3(cmd) do |stdin, stdout, stderr|
        svnerr = stderr.read
        if svnerr.respond_to?(:force_encoding)
          svnerr.force_encoding('UTF-8')
        end
      end

      if !svnerr.empty?
        logger.error("Setting revprop '#{propname}' for revision ##{identifier} on repository #{target} FAILED.")
        logger.error("used command:\n#{strip_credential(cmd)}")
        logger.error("error message:\n#{svnerr}")

        raise CommandFailed.new( l(:svn_set_rev_prop_error) )
      end
    end


    private

    def shellout3(cmd, &block)
      if logger && logger.debug?
        logger.debug "Shelling out: #{strip_credential(cmd)}"
      end
      begin
        Open3.popen3(cmd) do |stdin, stdout, stderr|
          block.call(stdin, stdout, stderr) if block_given?
        end
        ## If scm command does not exist,
        ## Linux JRuby 1.6.2 (ruby-1.8.7-p330) raises java.io.IOException
        ## in production environment.
        # rescue Errno::ENOENT => e
      rescue Exception => e
        msg = strip_credential(e.message)
        # The command failed, log it and re-raise
        logmsg = "SCM command failed, "
        logmsg += "make sure that your SCM command (e.g. svn) is "
        logmsg += "in PATH (#{ENV['PATH']})\n"
        logmsg += "You can configure your scm commands in config/configuration.yml.\n"
        logmsg += "#{strip_credential(cmd)}\n"
        logmsg += "with: #{msg}"
        logger.error(logmsg)
        raise CommandFailed.new(msg)
      end
    end

  end

end
