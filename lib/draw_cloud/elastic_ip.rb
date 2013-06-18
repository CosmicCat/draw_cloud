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
  class ElasticIp < Base
    class ElasticIpAssociation
      attr_accessor(:elastic_ip, :instance, :vpc)
      def initialize(elastic_ip, instance, vpc)
        @elastic_ip = elastic_ip
        @instance = instance
        @vpc = vpc
      end

      def resource_name
        elastic_ip.resource_name + "Association"
      end

      def to_h
        h = {
          "Type" => "AWS::EC2::EIPAssociation",
          "Properties" => { },
        }
        if instance.ec2_instance
          h["Properties"]["InstanceId"] = DrawCloud.ref(instance)
        elsif instance.network_interface
          h["Properties"]["NetworkInterfaceId"] = DrawCloud.ref(instance)
        else
          raise ArgumentError, "Unknown instance or network interface type #{instance.inspect}"
        end

        if vpc
          case elastic_ip
          when DrawCloud::ElasticIp
            h["Properties"]["AllocationId"] = DrawCloud.ref(elastic_ip[:allocation_id])
          else
            h["Properties"]["AllocationId"] = DrawCloud.ref(elastic_ip)
          end
        else
          h["Properties"]["EIP"] = DrawCloud.ref(elastic_ip)
        end
        h
      end
    end

    attr_accessor(:name, :instance_id, :domain)
    def initialize(name, options={}, &block)
      @name = name
      @domain = options.fetch(:domain, nil)
      @instance_id = options.fetch(:instance_id, nil)
      super(options, &block)
    end

    def elastic_ip
      self
    end

    def association
      ElasticIpAssociation.new(self, instance_id, vpc)
    end

    def load_into_config(config)
      config.cf_add_resource resource_name, self
      config.cf_add_resource(association.resource_name, association) if instance_id
      super(config)
    end

    def resource_name
      resource_style(name) + "EIP"
    end

    def to_h
      h = {
        "Type" => "AWS::EC2::EIP",
        "Properties" => {}
      }
      h["Properties"]["Domain"] = domain unless domain.nil?
      h["Properties"]["Domain"] = "vpc" if (domain.nil? && vpc)
      add_standard_properties(h)
    end
  end
end

