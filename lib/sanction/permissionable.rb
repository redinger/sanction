# Contains the methods / associations for a permissionable
module Sanction
  module Permissionable
    ROLE_ALIAS = "sanction_permissionable_role_query"

    def self.included(base)
      base.extend(Sanction::Permissionable::Base)
      base.send(:include, Sanction::Permissionable::With)
      base.send(:include, Sanction::Permissionable::For)

      base.send(:include, Sanction::Permissionable::Authorize)
      base.send(:include, Sanction::Permissionable::Unauthorize)
    
      base.send(:include, Sanction::Extensions::Total)
    end
  end
end
