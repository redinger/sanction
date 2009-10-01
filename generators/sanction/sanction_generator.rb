class SanctionGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.file 'initializer.rb', "config/initializers/sanction.rb"

      m.migration_template "migrate/create_roles.rb", "db/migrate", :migration_file_name => "create_roles"
    end
  end
end
