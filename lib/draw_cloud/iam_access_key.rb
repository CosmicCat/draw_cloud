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
  class IAMAccessKey < Base
    attr_accessor( :name, :serial, :status, :user_name )
    alias :user :user_name
    alias :user= :user_name=

    def initialize(name, options={}, &block)
      @name = name
      @user_name ||= options.fetch(:user, nil)
      @user_name ||= options.fetch(:user_name, nil)
      super(options, &block)
    end

    def iam_access_key
      self
    end

    def load_into_config(config)
      config.cf_add_resource resource_name, self
      super(config)
    end

    def to_h
      h = {
        "Type" => "AWS::IAM::AccessKey",
        "Properties" => {
          "Status" => status || "Active"
        }
      }
      h["Properties"]["Serial"] = serial unless serial.nil?
      h["Properties"]["UserName"] = DrawCloud.ref(user_name) unless user_name.nil?
      add_standard_properties(h)
    end
  end
end
