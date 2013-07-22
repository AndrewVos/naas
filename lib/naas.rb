require "naas/version"
require "sinatra/base"
require 'sinatra/synchrony'
require "json"

module Naas
  class Application < Sinatra::Base
    register Sinatra::Synchrony

    get "/message/:client_id" do
      wait_for_next_message params[:client_id]
    end

    def wait_for_next_message client_id
      loop do
        $messages ||= {}
        $messages[client_id] ||= []
        if $messages[client_id].any?
          message = $messages[client_id].shift
          return message.to_json
        end
        EM::Synchrony.sleep 0.1
      end
    end

    post "/message/:client_id" do
      $messages ||= {}
      $messages[params[:client_id]] ||= []
      $messages[params[:client_id]] << {:title => params[:title], :body => params[:body]}
    end
  end
end
