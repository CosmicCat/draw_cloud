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
  class IAMUser < Base
    attr_accessor( :name, :path, :groups, :login_profile, :password, :policies )

    def initialize(name, options={}, &block)
      @name = name
      @groups = []
      @policies = []
      super(options, &block)
    end

    def iam_user
      self
    end

    def load_into_config(config)
      config.cf_add_resource resource_name, self
      super(config)
    end

    def to_h
      h = {
        "Type" => "AWS::IAM::User",
        "Properties" => {
        }
      }
      h["Properties"]["Path"] = path if path
      h["Properties"]["Groups"] = groups.collect {|g| DrawCloud.ref(g)} if (groups && !groups.empty?)
      h["Properties"]["Policies"] = policies.collect {|p| DrawCloud.ref(p)} if (policies && !policies.empty?)
      h["Properties"]["LoginProfile"] = login_profile if login_profile
      h["Properties"]["LoginProfile"] = {"Password" => password} if (password && !h["Properties"].key?("LoginProfile"))
      add_standard_properties(h)
    end
  end
end
