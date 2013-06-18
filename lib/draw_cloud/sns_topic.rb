# encoding: utf-8
#
# Copyright:: Copyright (c) 2013, SweetSpot Diabetes Care, Inc.
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
  class SNSTopic < Base
    attr_accessor( :name,
                   :display_name,
                   :subscriptions )
    def initialize(name, options={}, &block)
      @name = name
      @subscriptions = options.fetch(:subscriptions, [])
      super(options, &block)
    end

    def add_subscription(endpoint, protocol)
      subscriptions << {:endpoint => endpoint, :protocol => protocol}
    end

    def sns_topic
      self
    end

    def load_into_config(config)
      config.cf_add_resource resource_name, self
      super(config)
    end

    def resource_name
      resource_style(name) + "SNSTopic"
    end

    def to_h
      h = {
        "Type" => "AWS::SNS::Topic",
        "Properties" => {
          "Subscription" => subscriptions.collect {|s| {"Endpoint" => DrawCloud.ref(s[:endpoint]), "Protocol" => DrawCloud.ref(s[:protocol])} }
        }
      }
      h["Properties"]["DisplayName"] = DrawCloud.ref(display_name) if display_name
      h
    end
  end
end
