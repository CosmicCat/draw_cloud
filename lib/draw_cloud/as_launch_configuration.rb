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
  class ASLaunchConfiguration < Base
    attr_accessor :name, :image_id, :instance_monitoring, :instance_type, :kernel_id, :key_name, :ram_disk_id, :security_groups, :user_data, :metadata, :tags
    alias :instance_class :instance_type
    alias :instance_class= :instance_type=
    alias :monitoring :instance_monitoring
    alias :monitoring= :instance_monitoring=
    def initialize(name, options={}, &block)
      @name = name
      @image_id = options.fetch(:image_id, nil)
      @instance_monitoring = options.fetch(:instance_monitoring, nil)
      @instance_type = options.fetch(:instance_type, nil)
      @kernel_id = options.fetch(:kernel_id, nil)
      @key_name = options.fetch(:key_name, nil)
      @ram_disk_id = options.fetch(:ram_disk_id, nil)
      @security_groups = options.fetch(:security_groups, nil)
      @user_data = options.fetch(:user_data, nil)
      super(options, &block)
    end

    def as_launch_configuration
      self
    end

    def load_into_config(config)
      config.cf_add_resource resource_name, self
      super(config)
    end

    def resource_name
      resource_style(name) + "LaunchConfig"
    end

    def to_h
      h = {
        "Type" => "AWS::AutoScaling::LaunchConfiguration",
        "Properties" => {
          "ImageId" => DrawCloud.ref(image_id),
          "InstanceType" => DrawCloud.ref(instance_type),
        }
      }
      p = h["Properties"]
      p["InstanceMonitoring"] = DrawCloud.ref(instance_monitoring) if instance_monitoring
      p["KernelId"] = DrawCloud.ref(kernel_id) if kernel_id
      p["KeyName"] = DrawCloud.ref(key_name) if key_name
      p["RamDiskId"] = DrawCloud.ref(ram_disk_id) if ram_disk_id
      p["SecurityGroups"] = security_groups.collect {|s| DrawCloud.ref(s)} if security_groups
      p["UserData"] = DrawCloud.ref(user_data) if user_data
      h["Metadata"] = DrawCloud.ref(metadata) unless metadata.nil? || metadata.empty?
      add_standard_properties(h)
    end
  end
end
