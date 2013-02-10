require "sinatra/base"
require "sinatra/reloader"
require "sinatra-initializers"
require "sinatra/r18n"

module OpenCity
  class Application < Sinatra::Base
    enable :logging, :sessions
    enable :dump_errors, :show_exceptions if development?

    configure :development do
      register Sinatra::Reloader
    end

    register Sinatra::Initializers
    register Sinatra::R18n

    before do
      session[:locale] = params[:locale] if params[:locale]
    end

    use Rack::Logger
    use Rack::Session::Cookie

    helpers OpenCity::HtmlHelpers

    get "/" do
      cache_control :public, max_age: 3600  # 1 hour
      haml :index
    end

    # utility for flushing cache
    get "/flush_cache" do
      unless ENV["MEMCACHE_SERVERS"].nil? or ENV["MEMCACHE_SERVERS"] == ''
        require 'dalli'
        dc = Dalli::Client.new
        dc.flush
      end
      redirect "/"
    end
  end
end
