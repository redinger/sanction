# Include hook code here
require 'sanction'

##
# ENSURE Sanction injections are performed
# 
unless Rails.configuration.cache_classes
  require 'dispatcher' unless defined?(::Dispatcher)

  Dispatcher.to_prepare do
    Sanction.do_injections!
  end
end
