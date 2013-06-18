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

require "json"
require "active_support/inflector"
require "deep_merge"

module DrawCloud
  class Base
    include Utilities
    include Locations

    attr_accessor( :mappings,
                   :parameters,
                   :resources,
                   :outputs,

                   :subnets,
                   :route_tables,
                   :network_acls,
                   :security_groups,
                   :iam_users,
                   :iam_policies,
                   :iam_access_keys,
                   :gateways,
                   :rdses,
                   :elastic_ips,
                   :network_interfaces,
                   :wait_handles,
                   :ec2_instances,
                   :as_launch_configurations,
                   :as_groups,
                   :vpcs,
                   :sns_topics,

                   :depends_on,
                   :deletion_policy,
                   :metadata,

                   :parent )

    def initialize(options={}, &block)
      @mappings = {}
      @parameters = {}
      @resources = {}
      @outputs = {}

      @subnets = []
      @route_tables = []
      @network_acls = []
      @security_groups = []
      @iam_users = []
      @iam_policies = []
      @iam_access_keys = []
      @gateways = []
      @rdses = []
      @ec2_instances = []
      @as_launch_configurations = []
      @as_groups = []
      @elastic_ips = []
      @network_interfaces = []
      @wait_handles = []
      @vpcs = []
      @sns_topics = []

      @parent = options.fetch(:parent, nil)

      self.instance_exec(self, &block) if block
    end

    def load_into_config(config)
      [@mappings, @parameters, @resources, @outputs].each do |i|
        i.each {|k,v| v.load_into_config(config)}
      end

      [@gateways, @subnets, @route_tables, @network_acls, @security_groups, @iam_users, @iam_policies, @iam_access_keys,
       @rdses, @ec2_instances, @as_launch_configurations, @as_groups, @elastic_ips, @network_interfaces, @wait_handles, @vpcs, @sns_topics].each do |a|
        a.each {|g| g.load_into_config(config) }
      end
    end

    def resource_name
      resource_style(name)
    end

    def add_standard_properties(hash)
      hash["DependsOn"] = DrawCloud.resource_name(depends_on) if depends_on
      hash["DeletionPolicy"] = DrawCloud.resource_style(deletion_policy) if deletion_policy
      hash["Metadata"] = DrawCloud.ref(metadata) unless metadata.nil?
      hash
    end

    def ref
      {"Ref" => resource_name}
    end

    def [](attribute)
      fngetatt(self, attribute)
    end

    ## Definers

    def create_mapping(name, map_by_function, values={})
      m = Map.new(name, map_by_function, {:parent => self}, values)
      mappings[m.resource_name] = m
      m
    end

    def create_output(name, options={}, &block)
      o = Output.new(name, options.merge(:parent => self), &block)
      outputs[o.resource_name] = o
      o
    end

    def create_parameter(name, type, options={}, &block)
      p = Parameter.new(name, type, options.merge(:parent => self), &block)
      parameters[p.resource_name] = p
      p
    end

    def create_service(name, options={}, &block)
      # NOOP
    end

    def create_vpc(name, cidr, options={}, &block)
      v = Vpc.new(name, cidr, options.merge(:parent => self), &block)
      vpcs << v
      v
    end

    def create_sns_topic(name, options={}, &block)
      s = SNSTopic.new(name, options.merge(:parent => self), &block)
      sns_topics << s
      s
    end

    def create_subnet(name, cidr, options={}, &block)
      # collisioncheck
      s = Subnet.new(name, cidr, options.merge(:parent => self), &block)
      subnets << s
      s
    end

    def create_route_table(name, options={}, &block)
      r = RouteTable.new(name, options.merge(:parent => self), &block)
      route_tables << r
      r
    end

    def create_network_acl(name, options={}, &block)
      a = NetworkAcl.new(name, options.merge(:parent => self), &block)
      network_acls << a
      a
    end

    def create_security_group(name, description=nil, options={}, &block)
      g = SecurityGroup.new(name, description, options.merge(:parent => self), &block)
      security_groups << g
      g
    end

    def create_iam_user(name, options={}, &block)
      u = IAMUser.new(name, options.merge(:parent => self), &block)
      iam_users << u
      u
    end

    def create_iam_policy(name, options={}, &block)
      p = IAMPolicy.new(name, options.merge(:parent => self), &block)
      iam_policies << p
      p
    end

    def create_iam_access_key(name, options={}, &block)
      a = IAMAccessKey.new(name, options.merge(:parent => self), &block)
      iam_access_keys << a
      a
    end

    def create_rds(name, options={}, &block)
      r = RDSInstance.new(name, options.merge(:parent => self), &block)
      rdses << r
      r
    end

    def create_ec2_instance_template(name, options={}, &block)
      EC2InstanceTemplate.new(name, options.merge(:parent => self), &block)
    end

    def create_ec2_instance(name, options={}, &block)
      e = EC2Instance.new(name, options.merge(:parent => self), &block)
      ec2_instances << e
      e
    end

    def create_as_launch_configuration(name, options={}, &block)
      lc = ASLaunchConfiguration.new(name, options.merge(:parent => self), &block)
      as_launch_configurations << lc
      lc
    end

    def create_as_group(name, options={}, &block)
      asg = ASGroup.new(name, options.merge(:parent => self), &block)
      as_groups << asg
      asg
    end

    def create_wait_handle(name, timeout=nil, options={}, &block)
      h = WaitHandle.new(name, timeout, options.merge(:parent => self), &block)
      wait_handles << h
      h
    end

    def create_elastic_ip(name, options={}, &block)
      eip = ElasticIp.new(name, options.merge(:parent => self), &block)
      elastic_ips << eip
      eip
    end

    def create_network_interface(name, options={}, &block)
      eni = NetworkInterface.new(name, options.merge(:parent => self), &block)
      network_interfaces << eni
      eni
    end

    ## Accessors (list below so grep works)
    # def elastic_ip
    # def internet_gateway
    # def network_acl
    # def rds
    # def route_table
    # def security_group
    # def subnet
    # def vpc
    [:elastic_ip, :network_interface, :ec2_instance, :as_launch_configuration, :as_group,
     :internet_gateway, :network_acl, :rds, :route_table, :security_group,
     :subnet, :vpc, :iam_user, :iam_policy, :iam_access_key].each do |accessor|
      self.class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
        def #{accessor}()
          if parent
            parent.#{accessor}
          else
            nil
          end
        end
      RUBY_EVAL
    end
  end
end
