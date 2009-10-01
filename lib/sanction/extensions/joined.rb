module Sanction
  module Extensions
    module Joined
      # Determine if a table (alias) has been joined against already.
      def self.already?(base, with)
        already_joined = false
        base.send(:scoped_methods).each do |sc| 
          if sc[:find] and sc[:find][:joins]
            if sc[:find][:joins].is_a? Array
              sc[:find][:joins].each do |join|
                already_joined = true if join.match(with)
              end
            elsif sc[:find][:joins].match(with)
              already_joined = true
            end
          end
        end
        already_joined
      end
    end
  end
end
