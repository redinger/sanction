module Sanction
  module Principal
    module Has
      def self.included(base)
        base.extend ClassMethods
        base.send(:include, InstanceMethods)   
      end
      
      module ClassMethods
        def self.extended(base)
          base.named_scope :has_scope_method, lambda {|*role_names| 
            if role_names.include? Sanction::Role::Definition::ANY_TOKEN
              {:conditions => [ROLE_ALIAS + ".name IS NOT NULL"]}
            else
              role_names.map! do |role_or_permission|
                roles_to_look_for = []
                potential_permission_to_roles = Sanction::Role::Definition.permission_to_roles_for_principal(role_or_permission, base)
                roles_to_look_for << potential_permission_to_roles.map(&:name) unless potential_permission_to_roles.blank?

                potential_roles = Sanction::Role::Definition.with(role_or_permission) & Sanction::Role::Definition.for(base)
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
   
        def has(*role_names)
          self.as_principal_self.has_scope_method(*role_names) 
        end
       
        def has?(*role_names)
          !has(*role_names).blank?
        end
                
        def has_all?(*role_names)
          result = nil
          role_names.each do |role|
            if(result.nil?) 
              result = self.has(role)
            else
              result = result & has(role)
            end
          end
          
          !result.blank?
        end
      end
      
      module InstanceMethods
        def has(*role_names)
          self.class.as_principal(self).has_scope_method(*role_names)
        end
        
        def has?(*role_names)
          !has(*role_names).blank? 
        end
        
        def has_all?(*role_names)
          self.class.as_principal(self).has_all?(*role_names)
        end         
      end
    end
  end
end
