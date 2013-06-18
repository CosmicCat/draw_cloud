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
  class RouteTableEntry < Base
    attr_accessor :name, :to, :via
    def initialize(name, to, via, options={})
      @name = name
      @to = to
      @via = via
      super(options)
    end

    def load_into_config(config)
      # FIXME: emit error if no table attached
      config.cf_add_resource resource_name, self
      super(config)
    end

    def resource_name
      route_table.resource_name + "To" + resource_style(name)
    end

    def to_h
      h = {
        "Type" => "AWS::EC2::Route",
        "Properties" => {
          "RouteTableId" => DrawCloud.ref(route_table),
          "DestinationCidrBlock" => to,
        }
      }
      if via.nil?
        throw ArgumentError, "Route #{resource_name} requires :via"
      elsif via.internet_gateway
        h["Properties"]["GatewayId"] = DrawCloud.ref(via.internet_gateway)
        # TODO: ["NetworkInterfaceId"]
      elsif via.ec2_instance
        h["Properties"]["InstanceId"] = DrawCloud.ref(via.ec2_instance)
      end

      add_standard_properties(h)
    end
  end
end
