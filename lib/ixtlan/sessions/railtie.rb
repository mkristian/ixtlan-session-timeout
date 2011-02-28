require 'rails'
require 'ixtlan/sessions/timeout'

module Ixtlan
  module Sessions
    class Railtie < Rails::Railtie

      config.before_configuration do |app|
        app.config.class.class_eval do
          attr_accessor :idle_session_timeout
        end
        app.config.idle_session_timeout = 5 #minutes
      end
      
      config.after_initialize do |app|
        ::ActionController::Base.send(:include, Ixtlan::Sessions::Timeout)
      end
    end
  end
end
