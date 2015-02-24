
module UserPatch

  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    base.class_eval do
      has_many :approval
    end
  end

  module ClassMethods
  end

  module InstanceMethods
  end
end

# User.send(:include, UserPatch)
