# encoding: UTF-8

module Rubypress

  class Client
    attr_reader :connection
    attr_accessor :port, :host, :path, :username, :password, :use_ssl, :default_post_fields

    def initialize(options = {})
      opts = {
        :port => 80,
        :use_ssl => true,
        :host => nil,
        :path => '/xmlrpc.php',
        :username => nil,
        :password => nil,
        :default_post_fields => ['post','terms','custom_fields']
      }.merge(options)
      self.port = opts[:port]
      self.host = opts[:host]
      self.path = opts[:path]
      self.username = opts[:username]
      self.password = opts[:password]
      self.use_ssl = opts[:use_ssl]
      self.default_post_fields = opts[:default_post_fields]
      self.connect
      self
    end

    def connect
      @connection = XMLRPC::Client.new(self.host, self.path, self.port,nil,nil,nil,nil,self.use_ssl,nil)
    end

    # FIXME: add tests
    def get_options(options = {})
      opts = {
        :blog_id => 0,
        :username => self.username,
        :password => self.password,
        :options => []
      }.merge(options)
      self.connection.call(
        "wp.getOptions", 
        opts[:blog_id], 
        opts[:username],
        opts[:password],
        opts[:options]
      )
    end
    
    def get_users_blogs(options = {})
      opts = {
        :blog_id => 0,
        :username => self.username,
        :password => self.password,
        :options => []
      }.merge(options)
      self.connection.call(
        "wp.getUsersBlogs", 
        opts[:username],
        opts[:password]
      )
    end    

    # FIXME: add tests
    def recent_posts(options = {})
      opts = {
        :blog_id => 0,
        :username => self.username,
        :password => self.password,
        :post_type => 'post',
        :post_status => 'publish',
        :number => 10,
        :offset => 0,
        :orderby => 'post_date',
        :order => 'asc',
        :fields => self.default_post_fields
      }.merge(options)
      self.get_posts opts
    end

    # FIXME: add tests
    def get_post(options = {})
      opts = {
        :blog_id => 0,
        :username => self.username,
        :password => self.password,
        :post_id => nil,
        :default_post_fields => self.default_post_fields
      }.merge(options)
      self.connection.call(
        "wp.getPost",
        opts[:blog_id],
        opts[:username],
        opts[:password],
        opts[:post_id]
      )
    end

    # FIXME: add tests
    def create_post(options = {})
      self.update_post(options)
    end

    # FIXME: add tests
    # FIXME: add taxonomy and custom field handling
    def update_post(options = {})
      opts = {
        :blog_id => 0,
        :username => self.username,
        :password => self.password,
        :post_type => "post",
        :post_status => "publish",
      }.merge(options)

      # required content options
      content = {
        :post_type => opts[:post_type],
        :post_status => opts[:post_status],
        :post_title => opts[:post_title],
        :post_content => opts[:post_content],
      }

      [ :post_date_gmt, :post_date, :post_author, :post_excerpt, :post_format, 
        :post_name, :post_password, :comment_status, :ping_status, :sticky, 
        :post_thumbnail, :post_parent ].each do |k|
        next unless opts.has_key?(k)
        content[k] = opts[k]
      end

      # require 'yaml'
      # puts y content

      params = if opts[:post_id].nil?
        ["wp.newPost", opts[:blog_id], opts[:username], opts[:password], content]
      else
        ["wp.editPost", opts[:blog_id], opts[:username], opts[:password], opts[:post_id], content]
      end

      self.connection.call( *params )
    end

    # FIXME: add tests
    def get_posts(options = {})
      opts = {
        :blog_id => 0,
        :username => self.username,
        :password => self.password,
      }.merge(options)

      filter = {}
      [:post_type, :post_status, :number, :offset, :orderby, :order].each do |k|
        filter[k] = opts[k] if opts.has_key?(k)
      end

      params = ["wp.getPosts", opts[:blog_id], opts[:username], opts[:password], filter]
      params.push opts[:fields] if opts.has_key?(:fields)

      self.connection.call( *params )
    end

    # FIXME: add tests
    # def delete_post(options => {})
    # end

    # FIXME: add tests
    # def get_post_types(options = {})
    # end

    # FIXME: add tests
    # FIXME: setting author requires anonymous xmlrpc posting or patching wp
    def create_comment(options = {})
      opts = {
        :blog_id => 0,
        :username => self.username,
        :password => self.password,
      }.merge(options)

      # required comment options
      comment = { :content => opts[:content] }

      [:comment_parent, :author, :author_url, :author_email].each do |k|
        next unless opts.has_key?(k)
        comment[k] = opts[k]
      end

      params = ["wp.newComment", opts[:blog_id], opts[:username], opts[:password], opts[:post_id], comment]

      self.connection.call( *params )
    end
  end

end
