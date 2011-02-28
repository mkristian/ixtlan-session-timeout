module Ixtlan
  module Sessions
    module Timeout
      private

      if defined? Ixtlan::Audit
        def session_user_logger
          @session_user_logger ||= Ixtlan::Audit::UserLogger.new(Rails.application.config.audit_manager)
        end
        
        def session_log(message)
          session_user_logger.log(self, message)
        end
      else
        def session_log(message)
          logger.debug(message)
        end
      end
      
      def expire_session
        session.clear
        #      reset_session
        session_timeout
        return false
      end
      
      protected
      
      def check_session_expiry
        if !session[:expires_at].nil? and session[:expires_at] < DateTime.now
          # Session has expired.
          session_log("session timeout")
          expire_session
        else
          # Assign a new expiry time
          session[:expires_at] = session_idle_timeout.minutes.from_now
          return true
        end
      end
      
      # IP binding is not very useful in the wild since some ISP use 
      # a different IP for each request, i.e. the session uses many IPs
      def check_session_ip_binding
        if !session[:session_ip].nil? and session[:session_ip] != request.headers['REMOTE_ADDR']
          # client IP has changed
          session_log("IP changed from #{session[:session_ip]} to #{request.headers['REMOTE_ADDR']}")
          expire_session
        else
          # Assign client IP
          session[:session_ip] = request.headers['REMOTE_ADDR']
          return true
        end
      end
      
      def check_session
        check_session_browser_signature && check_session_expiry
      end
      
      def check_session_browser_signature
        if !session[:session_browser_signature].nil? and session[:session_browser_signature] != retrieve_browser_signature
          # browser signature has changed
          session_log("browser signature changed from #{session[:session_browser_signature]} to #{retrieve_browser_signature}")
          expire_session
          return false
        else
          # Assign a browser signature
          session[:session_browser_signature] = retrieve_browser_signature
          return true
        end
      end
      
      def retrieve_browser_signature
        [request.headers['HTTP_USER_AGENT'],
         request.headers['HTTP_ACCEPT_LANGUAGE'],
         request.headers['HTTP_ACCEPT_ENCODING'],
         request.headers['HTTP_ACCEPT']].join('|')
      end
      
      def session_timeout
        respond_to do |format|
          format.html {
            @notice = "session timeout" unless @notice
            redirect_to ""
          }
          format.xml { head :unauthorized }
        end
      end
      
      def session_idle_timeout
        Rails.configuration.idle_session_timeout
      end
    end
  end
end
