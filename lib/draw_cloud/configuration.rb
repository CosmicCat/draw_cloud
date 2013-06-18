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
  class Configuration < Base
    attr_accessor :description
    def self.draw(&block)
      c = Configuration.new
      c.instance_exec(c, &block)
      puts JSON.pretty_generate(c.to_cf)
    end

    def initialize(options={}, &block)
      super(options, &block)
    end

    def to_cf
      h = {"AWSTemplateFormatVersion" => "2010-09-09"}
      h["Description"] = description if description

      c = Configuration.new
      self.load_into_config(c)

      { "Mappings" => c.mappings,
        "Parameters" => c.parameters,
        "Resources" => c.resources,
        "Outputs" => c.outputs }.each do |(key, values)|
        h[key] = Hash[*values.collect {|k,v| [k, v.to_h]}.flatten] unless values.empty?
      end
      h
    end

    def cf_add_mapping(name, map)
      mappings[name] = map
    end
    def cf_add_parameter(name, param)
      parameters[name] = param
    end
    def cf_add_resource(name, res)
      resources[name] = res
    end
    def cf_add_output(name, out)
      outputs[name] = out
    end
  end
end
