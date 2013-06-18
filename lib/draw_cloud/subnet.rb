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
  class Subnet < Base
    class SubnetRouteTableAssociation
      attr_accessor :subnet, :route_table
      def initialize(subnet, route_table)
        @subnet = subnet
        @route_table = route_table
      end

      def resource_name
        subnet.resource_name + "RouteTableAssociation"
      end

      def to_h
        { "Type" => "AWS::EC2::SubnetRouteTableAssociation",
          "Properties" => {
            "SubnetId" => DrawCloud.ref(subnet),
            "RouteTableId" => DrawCloud.ref(route_table),
          }
        }
      end
    end

    class SubnetNetworkAclAssociation
      attr_accessor :subnet, :network_acl
      def initialize(subnet, network_acl)
        @subnet = subnet
        @network_acl = network_acl
      end

      def resource_name
        subnet.resource_name + "NetworkAclAssociation"
      end

      def to_h
        { "Type" => "AWS::EC2::SubnetNetworkAclAssociation",
          "Properties" => {
            "SubnetId" => DrawCloud.ref(subnet),
            "NetworkAclId" => DrawCloud.ref(network_acl),
          }
        }
      end
    end

    attr_accessor :name, :cidr, :availability_zone, :route_table, :network_acl
    def initialize(name, cidr, options={}, &block)
      @name = name
      @cidr = cidr
      @availability_zone = options.fetch(:availability_zone, nil)
      @route_table = options.fetch(:route_table, nil)
      @network_acl = options.fetch(:network_acl, nil)
      super(options, &block)
    end

    def subnet
      self
    end

    def load_into_config(config)
      config.cf_add_resource resource_name, self
      if route_table
        route_table.load_into_config(config)
        assoc = SubnetRouteTableAssociation.new(self, route_table)
        config.cf_add_resource assoc.resource_name, assoc
      end
      if network_acl
        network_acl.load_into_config(config)
        assoc = SubnetNetworkAclAssociation.new(self, network_acl)
        config.cf_add_resource assoc.resource_name, assoc
      end
      super(config)
    end

    def to_h
      h = {
        "Type" => "AWS::EC2::Subnet",
        "Properties" => {
          "CidrBlock" => cidr,
        }
      }
      h["Properties"]["VpcId"] = DrawCloud.ref(vpc) if vpc
      h["Properties"]["AvailabilityZone"] = DrawCloud.ref(@availability_zone) if @availability_zone
      add_standard_properties(h)
    end
  end
end
