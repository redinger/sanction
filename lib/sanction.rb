# Sanction
# In the initializer, set the principals, permissionables, roles afterwhich
# the injections will take place based on these class vars.
#
module Sanction
#--------------------------------------------------#
#                   Public Api                     #
#--------------------------------------------------#
 def self.configure
    return if self.has_been_configured?

    self.has_been_configured = true
    
    begin
      yield self
    rescue ActiveRecord::StatementInvalid  
    end
  
    do_injections!
  end

  ##
  # Defining a role take the form:
  #  config.role :editor, [A, B] => [C, D], :having => [:can_edit]
  #  config.role :admin, [A, B] => [C, D], :includes => [:editor]
  #  
  def self.role(role_name, relationship_and_options)
    Sanction::Role::Definition.new(role_name, relationship_and_options)
  end
  
  #--------------------------------------------------#
  #                   Class Vars                     #
  #--------------------------------------------------#
    def self.principals=(principals)
      @@principals=principals
    end

    def self.principals
      @@principals ||= []
    end

    def self.permissionables=(permissionables)
      @@permissionables=permissionables
    end

    def self.permissionables
      @@permissionables ||= []
    end

    def self.has_been_configured=(flag)
      @@has_been_configured = flag
    end

    def self.has_been_configured?
      @@has_been_configured ||= false
    end
  
  private
  #--------------------------------------------------#
  #                   injections                     #
  #--------------------------------------------------#

  # Responsible for injecting the methods and associations for principals
  # and permissionables.
  def self.do_injections!
    inject_principals!
    inject_permissionables!
  end

  def self.inject_principals!
    self.principals.each do |principal|
      principal.send(:include, Sanction::Principal)
    end
  end
  
  def self.inject_permissionables!
    self.permissionables.each do |permissionable|
      permissionable.send(:include, Sanction::Permissionable)
    end
  end
end
