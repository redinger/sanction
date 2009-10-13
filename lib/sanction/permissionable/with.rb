module Sanction
  module Permissionable
    module With
      def self.included(base)
        base.extend ClassMethods
        base.send(:include, InstanceMethods)
      end
      module ClassMethods
        def self.extended(base)
          base.named_scope :with_scope_method, lambda {|*role_names|  
            if role_names.include? Sanction::Role::Definition::ANY_TOKEN
              {:conditions => [ROLE_ALIAS + ".name IS NOT NULL"]} if role_names.include? :any
            else
              role_names.map! do |role_or_permission|
                roles_to_look_for = []
                potential_permission_to_roles = Sanction::Role::Definition.permission_to_roles_for_permissionable(role_or_permission, base)
                roles_to_look_for << potential_permission_to_roles.map(&:name) unless potential_permission_to_roles.blank?
           
                potential_roles = Sanction::Role::Definition.with(role_or_permission) & (Sanction::Role::Definition.over(base) | Sanction::Role::Definition.globals)
                roles_to_look_for << potential_roles.map(&:name) unless potential_roles.blank?

                roles_to_look_for << role_or_permission if roles_to_look_for.blank?
                roles_to_look_for
              end
              role_names.flatten!
              role_names.uniq!

              conditions = role_names.map {|r| base.merge_conditions(["#{ROLE_ALIAS}.name = ?", r.to_s])}.join(" OR ")
              {:conditions => conditions}
            end
          }
        end

        def with(*role_names)
          self.as_permissionable_self.with_scope_method(*role_names) 
        end      
       
        def with?(*role_names)
          !with(*role_names).blank?
        end
                
        def with_all?(*role_names)
          result = nil
          role_names.each do |role|
            if result.nil?
              result = self.with(role)
            else
              result = result & self.with(role)
            end
          end

          !result.blank?
        end
      end
      
      module InstanceMethods
        def with(*role_names)
          self.class.as_permissionable(self).with_scope_method(*role_names)
        end

        def with?(*role_names)
          !with(*role_names).blank? 
        end
        
        def with_all?(*role_names)
          !self.class.as_permissionable(self).with_all?(*role_names)
        end         
      end
    end
  end
end
