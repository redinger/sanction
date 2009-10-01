#  Contains the methods/associations to make a principal.
module Sanction
  module Principal
    ROLE_ALIAS = "sanction_principal_role_query"
    def self.included(base) 
      base.extend Sanction::Principal::Base
      base.send(:include, Sanction::Principal::Has)
      base.send(:include, Sanction::Principal::Over)
      
      base.send(:include, Sanction::Principal::Grant)
      base.send(:include, Sanction::Principal::Revoke)

      base.send(:include, Sanction::Extensions::Total)
    end
  end
end
