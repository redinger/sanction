module Sanction
  module Principal
    module Over
      def self.included(base)
        base.extend ClassMethods
        base.send(:include, InstanceMethods)    
      end
      
      module InstanceMethods
        def over(*args)
          self.class.as_principal(self).over_scope_method(*args)
        end

        def over?(*args)
          !over(*args).blank?
        end

        def over_all?(*args)
          self.class.as_principal(self).over_all?(*args)
        end
      end
        
      module ClassMethods
        def self.extended(base)
          base.named_scope :over_scope_method, lambda {|*args|
            if args.include? Sanction::Role::Definition::ANY_TOKEN
              {:conditions => ["#{ROLE_ALIAS}.permissionable_type IS NOT NULL"]}
            else
              args.map {|a| raise Sanction::Role::Error::UnknownPermissionable.new("Unknown permissionable: #{a}") unless Sanction::Role::Definition.valid_permissionable? a }

              conds = []
              args.each do |arg|
                if arg.is_a? Class
                  conds << ["#{ROLE_ALIAS}.permissionable_type = ?", arg.name.to_s]  # Need id = nil here?
                else 
                  conds << ["#{ROLE_ALIAS}.permissionable_type = ? AND (#{ROLE_ALIAS}.permissionable_id = ? OR #{ROLE_ALIAS}.permissionable_id IS NULL)", arg.class.name.to_s, arg.id]
                end 
              end
              conditions = conds.map { |c| base.merge_conditions(c) }.join(" OR ")
              {:conditions => conditions}
            end
          }
          base.named_scope :over_all_single_argument, lambda {|arg|
            if arg == Sanction::Role::Definition::ANY_TOKEN
              {:conditions => ["#{ROLE_ALIAS}.permissionable_type IS NOT NULL"]}
            else
              raise Sanction::Role::Error::UnknownPermissionable.new("Unknown permissionable: #{arg}") unless Sanction::Role::Definition.valid_permissionable? arg

              if arg.is_a? Class
                {:conditions => ["#{ROLE_ALIAS}.permissionable_type = ? AND #{ROLE_ALIAS}.permissionable_id IS NULL", arg.name.to_s]}
              else
                {:conditions => ["#{ROLE_ALIAS}.permissionable_type = ? AND (#{ROLE_ALIAS}.permissionable_id = ? OR #{ROLE_ALIAS}.permissionable_id IS NULL)", arg.class.name.to_s, arg.id]}
              end
            end
          }
        end
  
        def over(*args)
          self.as_principal_self.over_scope_method(*args) 
        end
        
        def over?(*args)
          !over(*args).blank?
        end
 
        def over_all?(*args)
          result = nil
          args.each do |arg|
            if result.nil?
              result = self.over_all_single_argument(arg)
            else
              result = result & self.over_all_single_argument(arg)
            end
          end

          !result.blank? 
        end
      end
    end
  end
end
