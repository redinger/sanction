module Sanction
  module Principal
    module Revoke
      def self.included(base)
        base.extend RevokeMethod
        base.extend ClassMethods
        base.send(:include, RevokeMethod)
        base.send(:include, InstanceMethods)
      end

      module RevokeMethod
        def revoke(role_name, over = nil)
          if(over)
            self.remove_permissionable_role(role_name, over)            
          else
            self.remove_global_role(role_name)            
          end
        end
      end

      module InstanceMethods
        def remove_global_role(role_name)
          permission = Sanction::Role.global.find(:first, :conditions => {:principal_type => self.class.name.to_s, :principal_id => self.id, :name => role_name.to_s, :permissionable_type => nil})
          if permission
            permission.destroy
          else
            true
          end
        end
        
        def remove_permissionable_role(role_name, permissionable)
          if(permissionable.is_a? Class)
            if role = Sanction::Role.find(:first, :conditions => {:principal_type => self.class.name.to_s, :principal_id => self.id, :name => role_name.to_s, 
                                                                  :permissionable_type => permissionable.name.to_s, :permissionable_id => nil}) 
              role.destroy
            else
              true
            end
          else
            if role = Sanction::Role.find(:first, :conditions => {:principal_type => self.class.name.to_s, :principal_id => self.id, :name => role_name.to_s, 
                                                                  :permissionable_type => permissionable.class.name.to_s, :permissionable_id => permissionable.id})
              role.destroy
            else 
              true
            end
          end
        end
      end

      module ClassMethods
        def remove_global_role(role_name)
          permission = Sanction::Role.global.find(:first, :conditions => {:principal_type => self.name.to_s, :principal_id => nil, :name => role_name.to_s, :permissionable_type => nil})
          if permission
            permission.destroy
          else
            true
          end
        end
        
        def remove_permissionable_role(role_name, permissionable)
          if(permissionable.is_a? Class)
            if role = Sanction::Role.find(:first, :conditions => {:principal_type => self.name.to_s, :principal_id => nil, :name => role_name.to_s, 
                                                              :permissionable_type => permissionable.name.to_s, :permissionable_id => nil})
              role.destroy
            else 
              true
            end
          else
            if role = Sanction::Role.find(:first, :conditions => {:principal_type => self.name.to_s, :principal_id => nil, :name => role_name.to_s,
                                                              :permissionable_type => permissionable.class.name.to_s, :permissionable_id => permissionable.id}) 
              role.destroy
            else
              true
            end
          end
        end
      end
    end
  end
end
