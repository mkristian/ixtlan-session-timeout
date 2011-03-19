require 'ixtlan/sessions/timeout'
require 'logger'
require 'date'

class Controller
  
  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def session
    @session ||= {}
  end

  def request
    self
  end

  def headers
    @header ||= {}
  end

  def respond_to(&block)
    block.call(self)
  end

  def format
    self
  end

  def html(&block)
    block.call(self)
  end

  def xml(&block)
    block.call(self)
  end

  def head(status)
    @status = status
  end

  def redirect_to(loc)
    @location = loc
  end
  
end

class Rails
  
  def self.configuration
    self
  end

  def self.session_idle_timeout(val = nil)
    @val = MyDate.new(val) if val
    @val
  end

end

class MyDate

  def initialize(val)
    from_now(val)
  end

  def minutes
    self
  end

  def from_now(val = nil)
    @val ||= val if val
    DateTime.now + @val/1440.0
  end
end

describe Ixtlan::Sessions::Timeout do

  before :all do
    Controller.send :include, Ixtlan::Sessions::Timeout
    @controller = Controller.new
  end

  before :each do
    @controller.session.clear
  end

  it "should keep session when staying on same remote IP" do
    @controller.headers['REMOTE_ADDR'] = "127.0.1.1"
    @controller.session.size.should == 0
    @controller.send(:check_session_ip_binding).should be_true
    @controller.session.size.should == 1
    @controller.send(:check_session_ip_binding).should be_true
    @controller.session.size.should == 1
  end

  it "should kill session when changing remote IP" do
    @controller.headers['REMOTE_ADDR'] = "127.0.1.1"
    @controller.session.size.should == 0
    @controller.send(:check_session_ip_binding).should be_true
    @controller.session.size.should == 1

    @controller.headers['REMOTE_ADDR'] = "127.0.0.1"
    @controller.send(:check_session_ip_binding).should be_false
    @controller.session.size.should == 0
  end

  it "should keep session if idle timeout is in the future" do
    Rails.configuration.session_idle_timeout(1)
    @controller.session.size.should == 0
    @controller.send(:check_session_expiry).should be_true
    @controller.session.size.should == 1
    @controller.send(:check_session_expiry).should be_true
    @controller.session.size.should == 1
  end

  it "should kill session if idle timeout is in the past" do
    Rails.configuration.session_idle_timeout(-1)
    @controller.session.size.should == 0
    # first the session has not expiration_date so it will be set
    @controller.send(:check_session_expiry).should be_true
    @controller.session.size.should == 1 
    # now the expiration date is in the past so there is a timeout
    @controller.send(:check_session_expiry).should be_false
    @controller.session.size.should == 0
  end

  it "should use the controller session_idle_timeout if overwritten" do
    @controller.class.class_eval do
      def  session_idle_timeout
        MyDate.new(1)
      end
    end
    @controller.session.size.should == 0
    @controller.send(:check_session_expiry).should be_true
    @controller.session.size.should == 1
    @controller.send(:check_session_expiry).should be_true
    @controller.session.size.should == 1
  end

end
