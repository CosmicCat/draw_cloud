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
  class RDSSecurityGroup < Base
    attr_accessor :name, :description, :allows
    def initialize(name, description, options={}, &block)
      @name = name
      @description = description
      @allows = []
      super(options, &block)
    end

    def allow_in(designator)
      allows << designator
    end

    def load_into_config(config)
      config.cf_add_resource resource_name, self
      super(config)
    end

    def resource_name
      DrawCloud.resource_name(rds) + DrawCloud.resource_name(name) + "SG"
    end

    def to_h
      h = {
        "Type" => "AWS::RDS::DBSecurityGroup",
        "Properties" => {
          "GroupDescription" => description,
          "DBSecurityGroupIngress" => [],
        }
      }
      h["Properties"]["EC2VpcId"] = DrawCloud.ref(vpc) if vpc
      h["Properties"]["DBSecurityGroupIngress"] << {
        "CIDRIP" => "0.0.0.0/0"
      }
      h
    end
  end
end
