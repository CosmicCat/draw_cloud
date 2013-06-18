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
  class Map < Base
    class MapLookup
      attr_accessor :map, :key
      def initialize(map, key)
        @map = map
        @key = key
      end

      def ref
        {"Fn::FindInMap" => [map.resource_name, map.function_resource, key]}
      end
    end

    attr_accessor :name, :map_by_function, :values
    def initialize(name, map_by_function, options, values={})
      @name = name
      @map_by_function = map_by_function
      @values = values
      super(options)
    end

    def [](key)
      MapLookup.new(self, key)
    end

    def function_resource
      case map_by_function
      when :map_by_region
        {"Ref" => "AWS::Region"}
      when Parameter
        map_by_function.ref
      else
        raise ArgumentError, "Unknown map function #{map_by_function}"
      end
    end

    def load_into_config(config)
      config.cf_add_mapping resource_name, self
      super(config)
    end

    def to_h
      values
    end
  end
end
