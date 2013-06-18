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
  class ASGroup < Base
    NOTIFY_EC2_INSTANCE_LAUNCH          = "autoscaling:EC2_INSTANCE_LAUNCH"
    NOTIFY_EC2_INSTANCE_LAUNCH_ERROR    = "autoscaling:EC2_INSTANCE_LAUNCH_ERROR"
    NOTIFY_EC2_INSTANCE_TERMINATE       = "autoscaling:EC2_INSTANCE_TERMINATE"
    NOTIFY_EC2_INSTANCE_TERMINATE_ERROR = "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
    NOTIFY_EC2_TEST_NOTIFICATION        = "autoscaling:TEST_NOTIFICATION"
    ALL_NOTIFICATIONS = [ NOTIFY_EC2_INSTANCE_LAUNCH,
                          NOTIFY_EC2_INSTANCE_LAUNCH_ERROR,
                          NOTIFY_EC2_INSTANCE_TERMINATE,
                          NOTIFY_EC2_INSTANCE_TERMINATE_ERROR,
                          NOTIFY_EC2_TEST_NOTIFICATION ]
    ALL_ERRORS = [ NOTIFY_EC2_INSTANCE_LAUNCH_ERROR,
                   NOTIFY_EC2_INSTANCE_TERMINATE_ERROR ]
    ALL_ACTIVITY = [ NOTIFY_EC2_INSTANCE_LAUNCH,
                     NOTIFY_EC2_INSTANCE_LAUNCH_ERROR,
                     NOTIFY_EC2_INSTANCE_TERMINATE,
                     NOTIFY_EC2_INSTANCE_TERMINATE_ERROR ]

    attr_accessor :name, :availability_zones, :cooldown, :launch_configuration_name, :max_size, :min_size, :desired_capacity, :tags, :vpc_zone_identifier, :notification_configuration
    alias :subnets :vpc_zone_identifier
    alias :launch_configuration :launch_configuration_name
    alias :launch_configuration= :launch_configuration_name=
    def initialize(name, options={}, &block)
      @name = name
      @availability_zones = options.fetch(:availability_zones, [])
      @cooldown = options.fetch(:cooldown, nil)
      @launch_configuration_name = options.fetch(:launch_configuration_name, nil)
      @max_size = options.fetch(:max_size, nil)
      @min_size = options.fetch(:min_size, nil)
      @notification_configuration = options.fetch(:notification_configuration, nil)
      @desired_capacity = options.fetch(:desired_capacity, nil)
      @tags = options.fetch(:tags, [])
      @vpc_zone_identifier = options.fetch(:vpc_zone_identifier, nil)
      super(options, &block)
    end

    def as_group
      self
    end

    def notify(topic_arn, notification_types)
      self.notification_configuration = {:arn => topic_arn, :types => notification_types}
    end

    def vpc_zone_identifier=(subnets)
      if subnets.all? {|s| s.respond_to? :availability_zone }
        self.availability_zones = subnets.collect(&:availability_zone)
      end
      @vpc_zone_identifier = subnets
    end
    alias :subnets= :vpc_zone_identifier=

    def load_into_config(config)
      config.cf_add_resource resource_name, self
      super(config)
    end

    def resource_name
      resource_style(name) + "AS"
    end

    def to_h
      h = {
        "Type" => "AWS::AutoScaling::AutoScalingGroup",
        "Properties" => {
          "AvailabilityZones" => availability_zones.collect {|g| DrawCloud.ref(g) },
          "LaunchConfigurationName" => DrawCloud.ref(launch_configuration_name),
          "MaxSize" => max_size,
          "MinSize" => min_size,
          "Tags" => [], # FIXME
        }
      }
      p = h["Properties"]
      p["AvailabilityZones"] = DrawCloud.ref(availability_zones) if cooldown
      p["Cooldown"] = DrawCloud.ref(cooldown) if cooldown
      p["DesiredCapacity"] = DrawCloud.ref(desired_capacity) if desired_capacity
      p["VPCZoneIdentifier"] = vpc_zone_identifier.collect {|z| DrawCloud.ref(z) }
      p["NotificationConfiguration"] = {
        "TopicARN" => DrawCloud.ref(self.notification_configuration[:arn]),
        "NotificationTypes" => self.notification_configuration[:types],
      } if self.notification_configuration

      add_standard_properties(h)
    end
  end
end
