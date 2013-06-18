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
  class WaitHandle < Base
    class WaitCondition
      attr_accessor(:handle, :timeout, :count, :depends_on)
      def initialize(handle, timeout, count, depends_on)
        @handle = handle
        @timeout = timeout
        @count = count
        @depends_on = depends_on
      end

      def resource_name
        DrawCloud.resource_name(handle) + "Condition"
      end

      def to_h
        h = {
          "Type" => "AWS::CloudFormation::WaitCondition",
          "Properties" => {
            "Handle" => DrawCloud.ref(handle),
            "Timeout" => timeout
          }
        }
        h["DependsOn"] = DrawCloud.resource_name(depends_on) if depends_on
        h["Properties"]["Count"] = count unless count.nil?
        h
      end
    end

    attr_accessor(:name, :timeout, :count)
    def initialize(name, timeout=nil, options, &block)
      @name = name
      @timeout = timeout
      super(options, &block)
    end

    def [](attribute)
      fngetatt(condition, attribute)
    end

    def resource_name
      resource_style(name) + "WaitHandle"
    end

    def condition
      WaitCondition.new(self, timeout, count, depends_on)
    end

    def load_into_config(config)
      config.cf_add_resource resource_name, self
      config.cf_add_resource condition.resource_name, condition
      super(config)
    end

    def to_h
      # this class is a bit special - standard properties are added manually
      {"Type" => "AWS::CloudFormation::WaitConditionHandle"}
    end
  end
end
