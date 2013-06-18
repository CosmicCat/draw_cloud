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
  class Vpc < Base
    attr_accessor( :name,
                   :cidr )

    def initialize(name, cidr, options={}, &block)
      @name = name
      @cidr = cidr
      super(options, &block)
    end

    def vpc
      self
    end

    def gateway!
      if gateways.empty?
        gateways << InternetGateway.new("InternetGateway", :parent => self)
      end
      gateways.first
    end

    def load_into_config(config)
      config.cf_add_resource resource_name, self
      super(config)
    end

    def to_h
      h = {
        "Type" => "AWS::EC2::VPC",
        "Properties" => {
          "CidrBlock" => cidr,
          "InstanceTenancy" => "default",
        }
      }
      add_standard_properties(h)
    end
  end
end
