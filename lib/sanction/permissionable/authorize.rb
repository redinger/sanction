module Sanction
  module Permissionable
    module Authorize
      def self.included(base)
        base.extend AuthorizeMethod
        base.send(:include, AuthorizeMethod)
      end
 
      module AuthorizeMethod
        def authorize(role_name, for_principal_klass_or_instance)
          if Sanction::Role::Definition.valid_role? for_principal_klass_or_instance, role_name.to_sym, self
            for_principal_klass_or_instance.grant(role_name, self)   
          else
            false
          end
        end
      end
    end
  end
end
