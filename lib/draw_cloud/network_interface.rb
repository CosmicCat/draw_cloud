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
  class NetworkInterface < Base
    attr_accessor(:name, :description, :tags, :source_dest_check, :group_set, :subnet_id, :private_ip_address)
    alias :subnet :subnet_id
    alias :subnet= :subnet_id=
    alias :security_groups :group_set
    alias :security_groups= :group_set=
    def initialize(name, options={}, &block)
      @name = name
      @tags = {}
      super(options, &block)
    end

    def network_interface
      self
    end

    def load_into_config(config)
      config.cf_add_resource resource_name, self
      super(config)
    end

    def resource_name
      resource_style(name) + "ElasticNetworkInterface"
    end

    def elastic_ip=(eip)
      eip.instance_id = self
    end

    def default_tags
      {"Name" => resource_style(name)}
    end

    def to_h
      h = {
        "Type" => "AWS::EC2::NetworkInterface",
        "Properties" => {
          "SubnetId" => DrawCloud.ref(subnet_id)
        }
      }
      p = h["Properties"]
      p["Description"] = description unless description.nil?
      p["GroupSet"] = group_set.collect {|g| DrawCloud.ref(g)} unless (group_set.nil? || group_set.empty?)
      p["PrivateIpAddress"] = private_ip_address unless private_ip_address.nil?
      p["SourceDestCheck"] = source_dest_check unless source_dest_check.nil?
      all_tags = default_tags.merge(tags)
      p["Tags"] = hash_to_tag_array(all_tags) unless all_tags.empty?
      add_standard_properties(h)
    end
  end
end

