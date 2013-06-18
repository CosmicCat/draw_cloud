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
  class NetworkAcl < Base
    attr_accessor :name, :entries
    def initialize(name, options={}, &block)
      @name = name
      @entries = []
      super(options, &block)
    end

    def network_acl
      self
    end

    def allow_in(protocol, cidr=:any, ports_or_types=[])
      add_entry :allow, protocol, :ingress, cidr, ports_or_types
    end

    def allow_out(protocol, cidr=:any, ports_or_types=[])
      add_entry :allow, protocol, :egress, cidr, ports_or_types
    end

    def deny_in(protocol, cidr=:any, ports_or_types=[])
      add_entry :deny, protocol, :ingress, cidr, ports_or_types
    end

    def deny_out(protocol, cidr=:any, ports_or_types=[])
      add_entry :deny, protocol, :egress, cidr, ports_or_types
    end

    def provides(service)
    end

    def consumes(service)
    end

    def add_entry(action, protocol, direction, cidr, ports_or_types)
      entries.concat NetworkAclEntry.entries_from_spec(action, protocol, direction,
                                                       cidr, ports_or_types, :parent => self)
    end
    private :add_entry

    def load_into_config(config)
      config.cf_add_resource resource_name, self
      ingress_index = 1
      egress_index = 1
      entries.each do |e|
        if e.outgoing?
          e.index = egress_index * 10
          egress_index += 1
        else
          e.index = ingress_index * 10
          ingress_index += 1
        end

        e.load_into_config(config)
      end
      super(config)
    end

    def resource_name
      resource_style(name) + "NetworkACL"
    end

    def to_h
      h = {
        "Type" => "AWS::EC2::NetworkAcl",
        "Properties" => {}
      }
      h["Properties"]["VpcId"] = DrawCloud.ref(vpc) if vpc
      add_standard_properties(h)
    end
  end
end
