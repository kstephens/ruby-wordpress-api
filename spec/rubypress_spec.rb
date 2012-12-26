require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Rubypress" do

  it 'can instantiate' do
   init_wp_admin_connection.class.should == Rubypress::Client
  end

  it 'can connect' do
   # stub_request(:post, /xmlrpc.php$/).
   #     with {|req| req.body =~ /admin_user/}.
   #     to_return(:status => 200, :body => "", :headers => {})

    init_wp_admin_connection.class.should == Rubypress::Client
    init_wp_admin_connection.connection.class.should == XMLRPC::Client

    init_wp_editor_connection.get_options.class.should == Hash

    expect { init_wp_invalid_connection.get_options }.should raise_error(XMLRPC::FaultException)
  end
end
