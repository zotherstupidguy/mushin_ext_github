require_relative 'spec_helper'
require 'yaml'
require 'octokit'
require 'rugged'

describe "Github" do
  before do
    # flush all previous test data
    `rm -rf  DATA`
    @secrets 		= YAML::load_file "secrets.yml"
    @client 		= Octokit::Client.new :login    => @secrets["github"]["login"], :password => @secrets["github"]["password"]
    @username 		= 'pengwynn'
    @reponame 		= 'pingwynn'
    @slug 		= "#{@username}/#{@reponame}"
    @repo_url 		= @client.repo(@slug).git_url
    @local_repo_path 	= ("./DATA" + "/" + @slug)
  end 

  it "accesses github account via username and password" do
    user = @client.user
    user.login.must_equal @secrets["github"]["login"]
  end 

  it "takes a repo name and return its metadata" do
    repo = @client.repo @slug 
    repo.to_hash.empty?.must_equal false 
  end

  it "takes a repo slug and return its clone_url" do
    repo = @client.repo @slug
    repo.clone_url.must_equal "https://github.com/#{@slug}.git"
  end

  it "takes a repo slug and clones it locally" do
    Rugged::Repository.clone_at(@repo_url, @local_repo_path, {
      transfer_progress: lambda { |total_objects, indexed_objects, received_objects, local_objects, total_deltas, indexed_deltas, received_bytes|
	print("\r total_objects: #{total_objects}, indexed_objects: #{indexed_objects}, received_objects: #{received_objects}, local_objects: #{local_objects}, total_deltas: #{total_deltas}, indexed_deltas: #{indexed_deltas}, received_bytes: #{received_bytes}")
      }   
    })  
    File.directory?(@local_repo_path).must_equal true 
  end
end 
