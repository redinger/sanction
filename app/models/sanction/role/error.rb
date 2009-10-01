module Sanction
  class Role
    class Error < Exception
      class UnknownPrincipal < Sanction::Role::Error; end
      class UnknownPermissionable < Sanction::Role::Error; end
    end
  end
end
