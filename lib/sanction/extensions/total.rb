module Sanction
  module Extensions
    module Total
      def self.included(base)
        method_name = "total"

        if base.respond_to? method_name
          base.class_eval %Q{
            (class << self; self; end).send(:remove_method, '#{method_name}')
          }
        end

        base.class_eval %Q{
          def self.#{method_name}(conditions = {})
            count(:all, :select => "DISTINCT `#{base.table_name.to_s}`.`#{base.primary_key.to_s}`", :conditions => conditions)
          end
        }
      end 
    end
  end
end
