require 'mushin'
require 'octokit'
require_relative 'Github/version'

module Github
  class Ext 
    using Mushin::Ext 

    def initialize app=nil, opts={}, params={}
      @app 	= app
      @opts 	= opts
      @params 	= params 
    end
    def call env 
      env ||= Hash.new 

      case @opts[:cqrs]
      when :cqrs_query 
	#inbound code
	@app.call(env)
	#outbound code
      when :cqrs_command
	#inbound code
	@client 	= Octokit::Client.new(:login => @opts[:auth_username], :password => @opts[:auth_password])
	user 		= @client.user
	env[:login] 	= user.login

	#TODO in case of private repos the clone_url should be prefixed with a token and passed to other domain extenstions to handle the local work
	if !@params[:username].nil? && !@params[:reponame].nil? then 
	  @slug 		= @params[:username] + "/" + @params[:reponame] 
	  env[:slug]		= @slug
	  env[:repo_metadata]	= @client.repo(@slug).to_h
	  env[:clone_url] 	= @client.repo(@slug).clone_url
	elsif !@params[:slug].nil? then 
	  @slug 		= @params[:slug] 
	  env[:slug]		= @slug
	  env[:repo_metadata]	= @client.repo(@slug).to_h
	  env[:clone_url] 	= @client.repo(@slug).clone_url
	end
	@app.call(env)
	#outbound code
      else
	raise "you must specifiy if your cqrs call is command or query?"
      end
    end
  end

end
