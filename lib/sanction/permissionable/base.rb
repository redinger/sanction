module Sanction
  module Permissionable
    module Base
      def self.extended(base)
        base.class_eval %q{
          has_many :permissionable_roles, :as => :permissionable, :class_name => "Sanction::Role",
                   :finder_sql => 'SELECT * FROM `roles` WHERE `roles`.`permissionable_type` = "#{self.class.name.to_s}" AND (`roles`.`permissionable_id` = "#{id}" OR `roles`.`permissionable_id` IS NULL)'
        }

        base.named_scope :as_permissionable_self, lambda {
          already_joined = Sanction::Extensions::Joined.already? base, ROLE_ALIAS

          returned_scope = {:conditions => ["`#{ROLE_ALIAS}`.`permissionable_type` = ?", base.name.to_s], :select => "DISTINCT `#{base.table_name}`.*"}
          unless already_joined
            returned_scope.merge({:joins => "INNER JOIN `roles` AS `#{ROLE_ALIAS}` ON `#{ROLE_ALIAS}`.`permissionable_type` = '#{base.name.to_s}' AND
              (`#{ROLE_ALIAS}`.`permissionable_id` = `#{base.table_name}`.`id` OR `#{ROLE_ALIAS}`.`permissionable_id` IS NULL)"})
          end
        }

        base.named_scope :as_permissionable, lambda {|klass_instance|
          already_joined = Sanction::Extensions::Joined.already? base, ROLE_ALIAS
   
          returned_scope = {:conditions => ["`#{klass_instance.class.table_name}`.`id` = ?", klass_instance.id], :select => "DISTINCT `#{klass_instance.class.table_name}`.*"}
          unless already_joined
            returned_scope.merge({:joins => "INNER JOIN `roles` AS `#{ROLE_ALIAS}` ON `#{ROLE_ALIAS}`.`permissionable_type` = '#{klass_instance.class.name.to_s}' AND 
              (`#{ROLE_ALIAS}`.`permissionable_id` = '#{klass_instance.id}' OR `#{ROLE_ALIAS}`.`permissionable_id` IS NULL)"})
          end
        }
      end
    end
  end
end
