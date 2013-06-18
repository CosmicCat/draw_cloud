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
  class Output < Base
    attr_accessor :name, :description, :value
    def initialize(name, options={}, &block)
      @name = name
      super(options, &block)
    end

    def load_into_config(config)
      config.cf_add_output resource_name, self
      super(config)
    end

    def to_h
      h = {"Value" => DrawCloud.ref(value)}
      h["Description"] = description if description
      h
    end
  end
end
