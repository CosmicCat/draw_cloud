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
  module Utilities
    def region
      SimpleRef.new("AWS::Region")
    end

    def stack_name
      SimpleRef.new("AWS::StackName")
    end

    def fngetatt(resource, attribute_name)
      GetAttFunc.new(resource, attribute_name)
    end

    def fnbase64(arg)
      Base64Func.new(arg)
    end

    def fnjoin(delimiter, *args)
      JoinFunc.new(delimiter, args)
    end

    def resource_style(str)
      DrawCloud.resource_style(str)
    end

    def desplice(string)
      fnjoin("", *string.split('|CHOPHERE|').collect {|s| if s.start_with? 'YYYY' then YAML::load(s[4,s.length-4]) else s end })
    end

    def splice(string)
      out = '|CHOPHERE|'
      outref = DrawCloud.ref(string)
      case outref
      when String
        out += outref
      else
        out += 'YYYY' + YAML::dump(outref)
      end
      out += '|CHOPHERE|'
    end

    def hash_to_tag_array(hash)
      hash.collect {|(k,v)| {"Key" => k, "Value" => v} }
    end
  end
end
