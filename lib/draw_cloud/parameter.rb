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
  class Parameter < Base
    attr_accessor(:name, :description,
                  :allowed_pattern,
                  :type, :default, :no_echo,
                  :allowed_values, :max_length, :min_length,
                  :max_value, :min_value,
                  :constraint_description)
    def initialize(name, type, options={}, &block)
      @name = name
      @type = type
      super(options, &block)
    end

    def load_into_config(config)
      config.cf_add_parameter resource_name, self
      super(config)
    end

    def to_h
      h = {"Type" => DrawCloud.ref(type)}
      [:type, :default, :no_echo,
       :allowed_values, :max_length, :min_length,
       :max_value, :min_value,
       :constraint_description].each do |prop_str|
        prop = prop_str.intern
        h[resource_style(prop)] = DrawCloud.ref(self.send(prop)) unless self.send(prop).nil?
      end
      if !allowed_pattern.nil?
        h["AllowedPattern"] = case allowed_pattern
                              when Regexp
                                allowed_pattern.source
                              else
                                allowed_pattern.to_s
                              end
      end
      h
    end
  end
end
