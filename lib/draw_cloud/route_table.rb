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
  class RouteTable < Base
    attr_accessor :name, :routes
    def initialize(name, options={}, &block)
      @name = name
      @routes = []
      super(options, &block)
    end

    def route_table
      self
    end

    def to(name, to_cidr, options={})
      raise(Exeception, "No :via specified") unless options[:via]
      @routes << RouteTableEntry.new(name, to_cidr, options[:via], options.merge(:parent => self))
    end

    def load_into_config(config)
      config.cf_add_resource resource_name, self
      @routes.each {|r| config.cf_add_resource(r.resource_name, r)}
      super(config)
    end

    def resource_name
      resource_style(name) + "Table"
    end

    def to_h
      h = {
        "Type" => "AWS::EC2::RouteTable",
        "Properties" => {}
      }
      h["Properties"]["VpcId"] = DrawCloud.ref(vpc) if vpc
      add_standard_properties(h)
    end
  end
end
