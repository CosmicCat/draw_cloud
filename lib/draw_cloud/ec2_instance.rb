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
  class EC2Instance < Base
    attr_accessor(:name,
                  :availability_zone,
                  :disable_api_termination,
                  :image_id,
                  :instance_type,
                  :key_name,
                  :monitoring,
                  :placement_group_name,
                  :private_ip_address,
                  :source_dest_check,
                  :subnet_id,
                  :tags,
                  :user_data,
                  :metadata,
                  :template,
                  :eip_name)
    alias :instance_class :instance_type
    alias :instance_class= :instance_type=
    alias :instance_monitoring :monitoring
    alias :instance_monitoring= :monitoring=
    alias :ami :image_id
    alias :ami= :image_id=
    alias :subnet :subnet_id
    alias :subnet= :subnet_id=
    def initialize(name, options={}, &block)
      @name = name
      @tags = {}
      @template = options.fetch(:template, nil)
      super(options, &block)
    end

    def ec2_instance
      self
    end

    def elastic_ip=(eip)
      case eip
      when DrawCloud::ElasticIp
        eip.instance_id = self
        self.eip_name = nil
      else
        self.eip_name = eip
      end
    end

    def elastic_ip_association
      DrawCloud::ElasticIp::ElasticIpAssociation.new(eip_name, self, vpc)
    end

    def load_into_config(config)
      config.cf_add_resource resource_name, self
      config.cf_add_resource(elastic_ip_association.resource_name, elastic_ip_association) if eip_name
      super(config)
    end

    def resource_name
      resource_style(name) + "EC2"
    end

    def fetchmergeprop(name)
      s = {}
      s.deep_merge!(template.fetchmergeprop(name)) if template
      s.deep_merge!(self.send(name))
      s
    end

    def fetchprop(name)
      s = self.send(name)
      return s unless s.nil?
      return template.fetchprop(name) unless template.nil?
      nil
    end

    def fetchunionprop(name)
      if template
        p = template.fetchunionprop(name).clone
        p.concat self.send(name)
        p.uniq
      else
        self.send(name)
      end
    end

    def default_tags
      {"Name" => resource_style(name)}
    end

    def to_h
      h = {
        "Type" => "AWS::EC2::Instance",
        "Properties" => {
          "ImageId" => DrawCloud.ref(fetchprop :image_id),
          "InstanceType" => DrawCloud.ref(fetchprop :instance_type),
        }
      }
      p = h["Properties"]
      %w(availability_zone disable_api_termination key_name
         monitoring placement_group_name private_ip_address
         source_dest_check subnet_id user_data).each do |prop_str|
        prop = prop_str.intern
        p[resource_style(prop)] = DrawCloud.ref(fetchprop(prop)) unless fetchprop(prop).nil?
      end
      p["Tags"] = hash_to_tag_array(default_tags.merge(fetchmergeprop(:tags)))
      h["DependsOn"] = DrawCloud.resource_name(fetchprop(:depends_on)) unless fetchprop(:depends_on).nil?
      h["Metadata"] = DrawCloud.ref(fetchmergeprop(:metadata)) unless fetchmergeprop(:metadata).empty?

      enis = fetchunionprop(:network_interfaces)
      p["NetworkInterfaces"] = enis.enum_for(:each_with_index).collect do |e, i|
        { "NetworkInterfaceId" => DrawCloud.ref(e),
          "DeviceIndex" => (i+1).to_s }
      end unless enis.empty?

      security_groups = fetchunionprop(:security_groups)
      vpc_security_groups = security_groups.find_all(&:vpc)
      regular_security_groups = security_groups.reject(&:vpc)
      p["SecurityGroups"] = regular_security_groups.collect {|s| DrawCloud.ref(s) } unless regular_security_groups.empty?
      p["SecurityGroupIds"] = vpc_security_groups.collect {|s| DrawCloud.ref(s) } unless vpc_security_groups.empty?
      h
    end
  end
end
