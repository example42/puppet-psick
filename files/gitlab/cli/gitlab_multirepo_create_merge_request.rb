#!/usr/bin/env ruby
require 'gitlab'
require 'yaml'
GITLAB_CONFIG='/etc/gitlab-cli.yaml'
repo = ARGV[0]
source_branch = ARGV[1] ? ARGV[1] : 'integration'
destination_branch = ARGV[2] ? ARGV[2] : 'production'
last_commit=`git log -1 --oneline`
mr_title = ARGV[3] ? ARGV[3] : "MR:  #{last_commit} #{source_branch} to #{destination_branch}"

yaml_config = YAML.load(File.read(GITLAB_CONFIG)) 
config = yaml_config['defaults'].merge(yaml_config[repo])

project_id = config['project_id']
endpoint = config['api_endpoint']
private_token = config['private_token']
httparty = config['httparty_options']
gitlab_user = config['assigned_user']
gitlab_milestone = config['milestone']
gitlab_labels = config['labels']
autoadd_target = config['add_target_label']
autoadd_source = config['add_source_label']
default_target = config['prefix_target_label']
default_source = config['prefix_source_label']

if autoadd_target.to_s == "true"
  gitlab_labels=gitlab_labels.to_s+default_target.to_s+destination_branch
end

if autoadd_source.to_s == "true"
  gitlab_labels=gitlab_labels.to_s+default_source.to_s+source_branch
end

gitlab_labels=gitlab_labels.to_s.split(",").compact.reject(&:empty?).join(",")

if gitlab_labels == "''"
        gitlab_labels=""
end

Gitlab.endpoint = endpoint
Gitlab.private_token = private_token
Gitlab.httparty = eval(httparty)

assignee_id=""
user_list=Gitlab.team_members(project_id)
user_list.auto_paginate do |user|
  u=user.to_h
  if u["name"] == gitlab_user or u["username"] == gitlab_user
     assignee_id= u["id"]
  end
end

milestone_id=""
milestone_list=Gitlab.milestones(project_id)
milestone_list.auto_paginate do |milestone|
  m=milestone.to_h
  if m["title"] == gitlab_milestone
     milestone_id= m["id"]
  end
end

merge_requests = Gitlab.merge_requests(project_id)
merge_requests.auto_paginate do |merge_request|
  req=merge_request.to_h
  if req["state"] == "opened"
    id=req["iid"]
    sb=req["source_branch"]
    db=req["target_branch"]
    if source_branch == sb and destination_branch == db
      print "#{mr_title}: already exist with ID Number #{id}.\n"
      print "You only need to merge it.\n"
      exit 0
    end
  end
end

print "Creating #{mr_title}\n Assignee: Name=#{gitlab_user} - Id=#{assignee_id}\n Milestone: Title=#{gitlab_milestone} - Id=#{milestone_id}\n Labels: #{gitlab_labels}\n\n"

Gitlab.create_merge_request(project_id,"#{mr_title[0..200]}",{ source_branch: source_branch, target_branch: destination_branch, labels: gitlab_labels, assignee_id: assignee_id, milestone_id: milestone_id } )


