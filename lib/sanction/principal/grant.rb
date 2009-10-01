module Sanction
  module Principal
    module Grant
      def self.included(base)
        base.extend GrantMethod
        base.extend ClassMethods
        base.send(:include, GrantMethod)
        base.send(:include, InstanceMethods)
      end

      module GrantMethod
        def grant(role_name, over = nil)
          if Sanction::Role::Definition.valid_role? self, role_name, over
            if over.blank?
              if Sanction::Role::Definition.globals.map(&:name).include?(role_name)
                self.give_global_role(role_name)
              else
                raise Sanction::Role::Error.new("You must specify targets for a non global role")
              end
            else
              self.give_permissionable_role(role_name, over)
            end
          else
            false
          end
        end
      end
      
      module InstanceMethods
        protected
        def give_global_role(role_name)
          role_to_create = self.principal_roles.build(:name => role_name.to_s, :global => true)
          role_to_create.save
        end
        
        def give_permissionable_role(role_name, over)
          if(over.class == Class)
            role_to_create = self.principal_roles.build(:name => role_name.to_s, :permissionable_id => nil, :permissionable_type => over.to_s)
            role_to_create.save
          else
            role_to_create = self.principal_roles.build(:name => role_name.to_s, :permissionable_id => over.id, :permissionable_type => over.class.to_s)
            role_to_create.save
          end
        end  
      end

      module ClassMethods
        protected
        def give_global_role(role_name)
          role_to_create = Sanction::Role.new(:principal_type => self.name.to_s, :principal_id => nil, :name => role_name.to_s, :global => true)
          role_to_create.save
        end

        def give_permissionable_role(role_name, over)
          raise Sanction::Role::Error::UnknownPermissionable.new(over) unless Sanction::Role::Definition.valid_permissionable? over

          if over.is_a? Class
            role_to_create = Sanction::Role.new(:principal_type => self.name.to_s, :principal_id => nil, :name => role_name.to_s, :permissionable_type => over.name.to_s, :permissionable_id => nil)
            role_to_create.save
          else
            role_to_create = Sanction::Role.new(:principal_type => self.name.to_s, :principal_id => nil, :name => role_name.to_s, :permissionable_type => over.class.name.to_s, :permissionable_id => over.id)
            role_to_create.save
          end
        end
      end
    end
  end
end
