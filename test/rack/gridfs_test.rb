require File.join(File.dirname(__FILE__), '..', 'test_helper')

class Rack::GridFSTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def options_for_gridfs
    { :hostname => 'myhostname.mydomain', :port => 8765, :database => 'mydatabase', :prefix => 'myprefix' }
  end
  
  def stub_mongodb_connection
    Rack::GridFS.any_instance.stubs(:connect!).returns(true)
  end
  
  def test_database_options
    { :hostname => 'localhost', :port => 27017, :database => 'test', :prefix => 'gridfs' }
  end
  
  def db
    @db ||= Mongo::Connection.new(test_database_options[:hostname], test_database_options[:port]).db(test_database_options[:database])
  end
  
  def app 
    Rack::Builder.new do
      use Rack::GridFS, :hostname => 'localhost', :port => 27017, :database => 'test', :prefix => 'gridfs'
      run lambda { |env| [200, {'Content-Type' => 'text/plain'}, ["Hello, World!"]] }
    end
  end

  def load_artifact(filename, key, content_type)
    GridFS::GridStore.unlink(db, key)
    GridFS::GridStore.open(db, key, 'w', :content_type => content_type) do |dest|
      File.open(File.join(File.dirname(__FILE__), '..', 'artifacts', filename), 'r') do |orig|
        dest.puts orig.read
      end
    end
  end

  context "Rack::GridFS" do

    context "on initialization" do

      setup do
        stub_mongodb_connection
      end

      should "have a hostname option" do
        mware = Rack::GridFS.new(nil, options_for_gridfs)
        assert_equal options_for_gridfs[:hostname], mware.hostname
      end

      should "have a default hostname" do
        mware = Rack::GridFS.new(nil, options_for_gridfs.except(:hostname))
        assert_equal 'localhost', mware.hostname
      end

      should "have a port option" do
        mware = Rack::GridFS.new(nil, options_for_gridfs)
        assert_equal options_for_gridfs[:port], mware.port
      end

      should "have a default port" do
        mware = Rack::GridFS.new(nil, options_for_gridfs.except(:port))
        assert_equal Mongo::Connection::DEFAULT_PORT, mware.port
      end

      should "have a database option" do
        mware = Rack::GridFS.new(nil, options_for_gridfs)
        assert_equal options_for_gridfs[:database], mware.database
      end

      should "not have a default database" do
        mware = Rack::GridFS.new(nil, options_for_gridfs.except(:database))
        assert_nil mware.database
      end

      should "have a prefix option" do
        mware = Rack::GridFS.new(nil, options_for_gridfs)
        assert_equal mware.prefix, options_for_gridfs[:prefix]
      end
      
      should "have a default prefix" do
        mware = Rack::GridFS.new(nil, options_for_gridfs.except(:prefix))
        assert_equal mware.prefix, 'gridfs'
      end

      should "connect to the MongoDB server" do
        Rack::GridFS.any_instance.expects(:connect!).returns(true).once
        Rack::GridFS.new(nil, options_for_gridfs)
      end

    end

    should "delegate requests with a non-matching prefix" do
      %w( / /posts /posts/1 /posts/1/comments ).each do |path|
        get path
        assert last_response.ok?
        assert 'Hello, World!', last_response.body
      end
    end

    context "with a files in GridFS" do
      setup do
        load_artifact('test.txt', 'test.txt', 'text/plain')
        load_artifact('test.html', 'test.html', 'text/html')
      end

      should "return TXT files stored in GridFS" do
        get '/gridfs/test.txt'
        assert_equal "Lorem ipsum dolor sit amet.\n", last_response.body
      end

      should "return the proper content type for TXT files" do
        get '/gridfs/test.txt'
        assert_equal 'text/plain', last_response.content_type
      end

      should "return HTML files stored in GridFS" do
        get '/gridfs/test.html'
        assert_match /html.*?body.*Test/m, last_response.body
      end

      should "return the proper content type for HTML files" do
        get '/gridfs/test.html'
        assert_equal 'text/html', last_response.content_type
      end
    end

  end

end
