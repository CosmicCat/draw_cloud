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
  class InternetGateway < Base
    class InternetGatewayAttachment
      attr_accessor :gateway
      def initialize(gateway)
        @gateway = gateway
      end

      def resource_name
        gateway.resource_name + "Attach"
      end

      def to_h
        { "Type" => "AWS::EC2::VPCGatewayAttachment",
          "Properties" => {
            "VpcId" => DrawCloud.ref(gateway.vpc),
            "InternetGatewayId" => DrawCloud.ref(gateway),
          },
        }
      end
    end

    attr_accessor :name
    def initialize(name, options={}, &block)
      @name = name
      super(options, &block)
    end

    def internet_gateway
      self
    end

    def attachment
      InternetGatewayAttachment.new(self)
    end

    def load_into_config(config)
      config.cf_add_resource resource_name, self
      config.cf_add_resource attachment.resource_name, attachment
      super(config)
    end

    def to_h
      h = {"Type" => "AWS::EC2::InternetGateway"}
      add_standard_properties(h)
    end
  end
end
