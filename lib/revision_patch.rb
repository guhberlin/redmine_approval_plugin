

module RevisionAdapterPatch

  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    base.class_eval do
      attr_accessor :properties
      alias_method_chain :initialize, :properties
    end
  end

  module ClassMethods
  end

  module InstanceMethods

    def initialize_with_properties(attributes={})
      initialize_without_properties(attributes)

      self.properties = attributes[:properties] || []
    end
  end

end

# Redmine::Scm::Adapters::Revision.send(:include, RevisionAdapterPatch)
