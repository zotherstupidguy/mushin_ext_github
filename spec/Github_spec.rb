require_relative 'spec_helper'
require 'yaml'
require 'octokit'

describe "Github" do

  before do 
    @env 		= {} 

    @secrets 		= YAML::load_file "secrets.yml"

    @username 		= "pengwynn"
    @reponame 		= "pingwynn"
    @slug 		= @username + "/" + @reponame 
  end

  after do 
  end

  it "accesses github account via username and password" do
    opts 	= {:cqrs => :cqrs_command, :auth_username => @secrets["github"]["login"], :auth_password => @secrets["github"]["password"]}
    params 	= {}
    @ext 	= Github::Ext.new(Proc.new {}, opts, params)

    @env[:login].must_be_nil
    @ext.call(@env)
    @env[:login].must_equal @secrets["github"]["login"]
  end 

  it "takes a username/reponame or a slug and return the metadata of its repo" do
    opts 	= {:cqrs => :cqrs_command, :auth_username => @secrets["github"]["login"], :auth_password => @secrets["github"]["password"]}
    params 	= {:username => @username, :reponame => @reponame, :slug => @slug}
    @ext 	= Github::Ext.new(Proc.new {}, opts, params)

    @env[:repo_metadata].must_be_nil
    @ext.call(@env)
    @env[:repo_metadata].empty?.must_equal false 
  end

  it "takes a username/reponame or a slug and return the clone_url of its repo" do
    opts 	= {:cqrs => :cqrs_command, :auth_username => @secrets["github"]["login"], :auth_password => @secrets["github"]["password"]}
    params 	= {:username => @username, :reponame => @reponame, :slug => @slug}
    @ext 	= Github::Ext.new(Proc.new {}, opts, params)

    @env[:clone_url].must_be_nil
    @ext.call(@env)
    @env[:clone_url].must_equal "https://github.com/#{@slug}.git"
  end

  it "doesn't raise an error if both username/reponame and a slug are nil or empty" do
    opts 	= {:cqrs => :cqrs_command, :auth_username => @secrets["github"]["login"], :auth_password => @secrets["github"]["password"]}
    params 	= {:username => nil, :reponame => nil, :slug => nil}
    @ext 	= Github::Ext.new(Proc.new {}, opts, params)

    @ext.call(@env)
    @env[:repo_metadata].must_be_nil
    @env[:clone_url].must_be_nil
  end

end
