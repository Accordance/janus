require 'grape'
require 'grape-entity'
require 'faraday'

require_relative 'api/defaults'

module API
  class DeployController < Grape::API
    include API::Defaults

    resource :deploy do
      params do
        requires :id, type: String, desc: 'Application id'
        requires :version, type: String, desc: 'Version number'
      end
      post :start, http_codes: [
        [200, 'OK'],
        [403, 'Deploy Not Allowed']
      ]  do
        
        conn = Faraday.new(:url => 'http://192.168.99.100:8000')
            response = conn.post do |req| 
              req.url '/apps/deploy'
              req.headers['Content-Type'] = 'application/json'
              req.body = "{ \"id\": \"#{params[:id]}\", \"version\" : \"#{params[:version]}\" }"
            end
        if response.status == 200
          status 200
        elsif response.status == 403
          error! "Deployment Lock is Active", 403
        end
      end

      post :complete, http_codes: [
        [200, 'OK'],
        [403, 'Lock release failed']
      ]	do
        
        conn = Faraday.new(:url => 'http://192.168.99.100:8000')
        response = conn.post do |req| 
          req.url '/apps/release-deploy'
          req.headers['Content-Type'] = 'application/json'
          req.body = "{ \"id\": \"#{params[:id]}\", \"version\" : \"#{params[:version]}\" }"
        end
        if response.status == 200
          status 200
        elsif response.status == 403
          error! "Lock is not Active", 403
        end
      end
    end
  end
end

