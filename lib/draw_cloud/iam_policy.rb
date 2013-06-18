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
  class IAMPolicy < Base
    attr_accessor( :name, :policy_document, :groups, :users, :statements )
    alias :document :policy_document
    alias :document= :policy_document=

    def initialize(name, options={}, &block)
      @name = name
      @groups = []
      @users = []
      @statements = []
      super(options, &block)
    end

    def iam_policy
      self
    end

    def allow(statement_properties={})
      @statements << resourcify_statement_property(statement_properties.merge(:effect => "Allow"))
    end

    def deny(statement_properties={})
      @statements << resourcify_statement_property(statement_properties.merge(:effect => "Deny"))
    end

    def resourcify_statement_property(hash)
      hash.each_with_object({}) {|(k,v),x| x[DrawCloud.resource_style(k)] = v }
    end

    def load_into_config(config)
      config.cf_add_resource resource_name, self
      super(config)
    end

    def to_h
      h = {
        "Type" => "AWS::IAM::Policy",
        "Properties" => {
          "PolicyName" => resource_name,
          "PolicyDocument" => {
            "Statement" => @statements.collect do |s|
              DrawCloud.ref(s)
            end
          }
        }
      }
      h["Properties"]["Groups"] = groups.collect {|g| DrawCloud.ref(g)} if (groups && !groups.empty?)
      h["Properties"]["Users"] = users.collect {|u| DrawCloud.ref(u)} if (users && !users.empty?)
      add_standard_properties(h)
    end
  end
end
