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
  class GetAttFunc
    attr_accessor :resource, :attribute_name
    def initialize(resource, attribute_name)
      @resource = resource
      @attribute_name = attribute_name
    end

    def ref
      {"Fn::GetAtt" => [DrawCloud.resource_name(resource), DrawCloud.resource_style(attribute_name)]}
    end
  end
end
