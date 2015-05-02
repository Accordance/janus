require 'spec_helper_integration'
require_relative '../../server/controllers/api/defaults'
require_relative '../../server/controllers/queues_controller'

describe API::QueuesController do
  let :app do
    API::QueuesController
  end

  def create_deployment_lock(env, active = false)
    lock = DeploymentLocksProvider::DeploymentLock.new(
      environment: env,
      active: active
    )
    lock._id = "#{env}:master"
    lock.save
  end

  it 'accepts deploy-started report and fails when deploy lock is enabled' do
    env = 'f1'
    json             = { app:        ['test1,test2'], env: env, action: 'deploy',
                         status_url: 'http://server01.accordance.net/jenkins/job/app/100/api/json',
                         status:     'started', mc: 'true' }
    received_message = JSON.generate(json)
    fake_json_value  = '{}'
    create_deployment_lock env, true

    matcher = hash_including(
      'time',
      'env',
      'app'        => json[:app],
      'action'     => json[:action],
      'status_url' => json[:status_url],
      'status'     => json[:status],
      'mc'         => json[:mc],
      'env'        => json[:env]
    )
    allow(JSON).to receive(:generate).with(matcher) { fake_json_value }
    # allow(JobProcessors::ProcessBuildJob).to receive(:perform_async).with(fake_json_value) { true }

    # post "/data", '{"x":42}', { 'CONTENT_TYPE' => 'application/json' }
    post '/queues/build-messages', message: received_message

    # expect(last_response).to raise_error #(Services::QueueService::UnknownAction)
    expect(last_response.status).to eq(401)
    expect(last_response.body).to be_json('error' => 'Deployment lock is active')
  end

  it 'accepts deploy-started report and enqueus event when deploy lock disabled' do
    env = 'f1'
    json             = { app:        ['test1,test2'], env: env, action: 'deploy',
                         status_url: 'http://server01.accordance.net/jenkins/job/app/100/api/json',
                         status:     'started', mc: 'true' }
    received_message = JSON.generate(json)
    fake_json_value  = '{}'
    create_deployment_lock env, false

    matcher = hash_including(
      'time',
      'env',
      'app'        => json[:app],
      'action'     => json[:action],
      'status_url' => json[:status_url],
      'status'     => json[:status],
      'mc'         => json[:mc],
      'env'        => json[:env]
    )
    allow(JSON).to receive(:generate).with(matcher) { fake_json_value }
    # allow(JobProcessors::ProcessBuildJob).to receive(:perform_async).with(fake_json_value) { true }
    # args = {
    #   'class' => 'JobProcessors::ProcessBuildJob',
    #   'args' => [json]
    # }
    # allow(Sidekiq::Client).to receive(:push).with do |options|
    # puts options
    # (hash_including('class' => 'JobProcessors::ProcessBuildJob', 'args' => array_including(json)))
    # end
    # allow(Services::QueueService).to receive(:process_build_job_async)
    allow(Sidekiq::Client).to receive(:push) do |arg|
      expect(arg).to be_a Hash
      expect(arg).to include('class' => 'JobProcessors::ProcessBuildJob')
      expect(arg).to include('args')
      expect(arg['args']).to be_a Array
      expect(arg['args'].size).to be == 1
      t_args = arg['args'][0]

      expect(t_args).to include(
        app: ['test1,test2'],
        env: 'f1',
        action: 'deploy',
        status_url: 'http://server01.accordance.net/jenkins/job/app/100/api/json',
        status: 'started',
        mc: 'true',
        time: /.+/
      )
      # match(
      # 'env' => a_value == 'f1'
      # :a => {
      #   :b => a_collection_containing_exactly(
      #     an_instance_of(Fixnum),
      #     a_string_starting_with("f")
      #   ),
      #   :c => { :d => (a_value < 3) }
      # }
      # )
    end

    post '/queues/build-messages', message: received_message

    # expect(last_response).to raise_error #(Services::QueueService::UnknownAction)
    expect(last_response.status).to eq(201)
    expect(last_response.body).to be_json({})
  end
end
