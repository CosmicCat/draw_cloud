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
  class SecurityGroup < Base

    attr_accessor :name, :description, :ingress_rules
    def initialize(name, description=nil, options={}, &block)
      @name = name
      @description = description || name.to_s
      @ingress_rules = []
      super(options, &block)
    end

    def security_group
      self
    end

    def allow_security_group_in(protocol, source_security_group_id, from_port, to_port)
      ingress_rules << {
        "IpProtocol" => protocol.to_s,
        "SourceSecurityGroupId" => DrawCloud.ref(source_security_group_id),
        "FromPort" => from_port.to_s,
        "ToPort" => to_port.to_s
      }
    end

    def allow_cidr_in(protocol, cidr, from_port, to_port)
      ingress_rules << {
        "IpProtocol" => protocol.to_s,
        "CidrIp" => cidr,
        "FromPort" => from_port.to_s,
        "ToPort" => to_port.to_s
      }
    end

    def provides(services, options={})
    end

    def consumes(services, options={})
    end

    def load_into_config(config)
      config.cf_add_resource resource_name, self
      super(config)
    end

    def resource_name
      resource_style(name) + "SecurityGroup"
    end

    def check_validity
      raise(ArgumentError, "Bad description for #{name.inspect} => #{description.inspect}. Must be [a-zA-Z0-9_ -]{0,255}") unless description =~ /^[a-zA-Z0-9_ -]{0,255}$/
    end

    def to_h
      check_validity
      h = {
        "Type" => "AWS::EC2::SecurityGroup",
        "Properties" => {
          "GroupDescription" => description,
          "SecurityGroupIngress" => ingress_rules,
          "SecurityGroupEgress" => [],
        }
      }
      h["Properties"]["VpcId"] = DrawCloud.ref(vpc) if vpc
      add_standard_properties(h)
    end
  end
end
