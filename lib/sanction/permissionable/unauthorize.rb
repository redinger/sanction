module Sanction
  module Permissionable
    module Unauthorize
      def self.included(base)
        base.extend UnauthorizeMethod
        base.send(:include, UnauthorizeMethod)
      end
    end
    module UnauthorizeMethod
      def unauthorize(role_name, for_principal_klass_or_instance)
        for_principal_klass_or_instance.revoke(role_name, self)
      end
    end
  end
end
