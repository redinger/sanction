module Sanction
  module Permissionable
    module For
      def self.included(base)
        base.extend ClassMethods
        base.send(:include, InstanceMethods)
      end
      
      module ClassMethods
        def self.extended(base)
          base.named_scope :for_scope_method, lambda {|*args| 
            if args.include? Sanction::Role::Definition::ANY_TOKEN
              {:conditions => ["#{ROLE_ALIAS}.principal_type IS NOT NULL"]}
            else
              args.map {|a| raise Sanction::Role::Error::UnknownPrincipal.new("Unknown principal: #{a}") unless Sanction::Role::Definition.valid_principal? a }

              conds = []
              args.each do |arg|
                if arg.is_a? Class
                  conds << ["#{ROLE_ALIAS}.principal_type = ?", arg.to_s]
                else
                  conds << ["#{ROLE_ALIAS}.principal_type = ? AND (#{ROLE_ALIAS}.principal_id = ? OR #{ROLE_ALIAS}.principal_id IS NULL)", arg.class.name.to_s, arg.id]
                end 
              end 
              conditions = conds.map { |c| base.merge_conditions(c) }.join(" OR ")
              {:conditions => conditions}
            end
          }
          base.named_scope :for_all_single_argument, lambda {|arg|
            if arg == Sanction::Role::Definition::ANY_TOKEN
              {:conditions => ["#{ROLE_ALIAS}.principal_type IS NOT NULL"]}
            else
              raise Sanction::Role::Error::UnknownPrincipal.new("Unknown principal: #{arg}") unless Sanction::Role::Definition.valid_principal? ar

              if arg.is_a? Class
                {:conditions => ["#{ROLE_ALIAS}.principal_type = ? AND #{ROLE_ALIAS}.principal_id IS NULL", arg.name.to_s]}
              else
                {:conditions => ["#{ROLE_ALIAS}.principal_type = ? AND (#{ROLE_ALIAS}.principal_id = ? OR #{ROLE_ALIAS}.principal_id IS NULL)", arg.class.name.to_s, arg.id]}
              end
            end
          }
        end
        
        def for(*args)
          self.as_permissionable_self.for_scope_method(*args)
        end
      
        def for?(*args)
          !self.for(*args).blank?
        end

        def for_all?(*args)
          result = nil
          args.each do |arg|
            if result.nil?
              result = self.for_all_single_argument(arg)
            else
              result = result & self.for_all_single_argument(arg)
            end
          end
         
          !result.blank?
        end
      end
      
      module InstanceMethods           
        def for(*args)
          self.class.as_permissionable(self).for_scope_method(*args)
        end

        def for?(*args)
          !self.for(*args).blank?
        end        
      
        def for_all?(*args)
          !self.class.as_permissionable(self).for_all?(*args)
        end
      end
    end
  end
end
