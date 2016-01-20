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
        
        response = Faraday.post("http://192.168.99.100:8000/apps/deploy/#{params[:id]}")
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
        
        response = Faraday.post("http://192.168.99.100:8000/apps/release-deploy/#{params[:id]}")
        if response.status == 200
          status 200
        elsif response.status == 403
          error! "Lock could not be released", 403
        end
      end
    end
  end
end

