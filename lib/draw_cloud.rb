# encoding: utf-8
#
# Copyright:: Copyright (c) 2012, SweetSpot Diabetes Care, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this work except in compliance with the License. You may
# obtain a copy of the License in the LICENSE file, or at:
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied. See the License for the specific language governing
# permissions and limitations under the License.
#

module DrawCloud
  def self.ref(object)
    if object.respond_to? :ref
      object.ref
    elsif object.is_a? Symbol
      resource_style(object)
    elsif object.respond_to? :each_pair
      object.each_with_object({}) {|(k,v),x| x[k] = DrawCloud.ref(v)}
    else
      object
    end
  end

  def self.resource_style(str)
    str.to_s.camelize
  end

  def self.resource_name(o)
    if o.respond_to? :resource_name
      o.resource_name
    else
      resource_style(o)
    end
  end

  require_relative "draw_cloud/utilities"
  require_relative "draw_cloud/locations"
  require_relative "draw_cloud/base"
  require_relative "draw_cloud/simple_ref"
  require_relative "draw_cloud/join_func"
  require_relative "draw_cloud/base64_func"
  require_relative "draw_cloud/get_att_func"
  require_relative "draw_cloud/configuration"
  require_relative "draw_cloud/map"
  require_relative "draw_cloud/parameter"
  require_relative "draw_cloud/output"
  require_relative "draw_cloud/vpc"
  require_relative "draw_cloud/sns_topic"
  require_relative "draw_cloud/security_group"
  require_relative "draw_cloud/iam_policy"
  require_relative "draw_cloud/iam_user"
  require_relative "draw_cloud/iam_access_key"
  require_relative "draw_cloud/subnet"
  require_relative "draw_cloud/network_acl"
  require_relative "draw_cloud/network_acl_entry"
  require_relative "draw_cloud/route_table"
  require_relative "draw_cloud/route_table_entry"
  require_relative "draw_cloud/internet_gateway"
  require_relative "draw_cloud/rds_instance"
  require_relative "draw_cloud/rds_security_group"
  require_relative "draw_cloud/wait_handle"
  require_relative "draw_cloud/ec2_instance"
  require_relative "draw_cloud/ec2_instance_template"
  require_relative "draw_cloud/as_launch_configuration"
  require_relative "draw_cloud/as_group"
  require_relative "draw_cloud/elastic_ip"
  require_relative "draw_cloud/network_interface"
end
