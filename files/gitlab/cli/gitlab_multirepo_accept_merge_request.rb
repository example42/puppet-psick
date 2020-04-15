#!/usr/bin/env ruby
require 'gitlab'
require 'yaml'
GITLAB_CONFIG='/etc/gitlab-cli.yaml'
repo = ARGV[0]
source_branch = ARGV[1] ? ARGV[1] : 'integration'
destination_branch = ARGV[2] ? ARGV[2] : 'production'
last_commit=`git log -1 --oneline`
mr_title = ARGV[3] ? ARGV[3] : "Merged:  #{last_commit} from #{source_branch} to #{destination_branch}"

yaml_config = YAML.load(File.read(GITLAB_CONFIG))
config = yaml_config['defaults'].merge(yaml_config[repo])

project_id = config['project_id']
endpoint = config['api_endpoint']
private_token = config['private_token']
httparty = config['httparty_options']

Gitlab.endpoint = endpoint
Gitlab.private_token = private_token
Gitlab.httparty = eval(httparty)

merge_requests = Gitlab.merge_requests(project_id)
merge_requests.auto_paginate do |merge_request|
  req=merge_request.to_h
  if req["state"] == "opened"
    mr_id=req["iid"]
    sb=req["source_branch"]
    db=req["target_branch"]
    if source_branch == sb and destination_branch == db
      print "Merging id #{project_id}/#{mr_id}: #{mr_title}\n"
      Gitlab.accept_merge_request(project_id,mr_id, { merge_when_pipeline_succeeds: true, merge_commit_message: "#{mr_title}", should_remove_source_branch: false })
      exit 0
    end
  end
end

print "Error: Merge Request NOT Found: #{mr_title}\n"
exit 1

