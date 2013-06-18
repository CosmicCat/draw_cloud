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
  class RDSInstance < Base
    class RDSSubnetGroup < Base
      attr_accessor :rds, :rds_subnets
      def initialize(rds, rds_subnets)
        @rds_subnets = rds_subnets
        @rds = rds
      end

      def resource_name
        rds.resource_name + "SubnetGroup"
      end

      def to_h
        { "Type" => "AWS::RDS::DBSubnetGroup",
          "Properties" => {
            "DBSubnetGroupDescription" => "Security group for RDS" + DrawCloud.resource_name(rds),
            "SubnetIds" => rds_subnets.collect { |s| DrawCloud.ref(s) },
          }
        }
      end
    end

    attr_accessor( :name,
                   :allocated_storage,
                   :db_instance_class,
                   :master_username,
                   :master_user_password,
                   :db_security_groups,
                   :engine,
                   :engine_version,
                   :multi_az,
                   :rds_subnets,
                   :db_snapshot_identifier,
                   :auto_minor_version_upgrade,
                   :backup_retention_period,
                   :iops )
    alias :instance_class :db_instance_class
    alias :instance_class= :db_instance_class=
    alias :master_password :master_user_password
    alias :master_password= :master_user_password=
    def initialize(name, options={}, &block)
      @name = name
      @db_security_groups = []
      @rds_subnets = []
      super(options, &block)
    end

    def rds
      self
    end

    def load_into_config(config)
      config.cf_add_resource resource_name, self
      db_security_groups.each {|g| g.load_into_config(config) }
      unless rds_subnets.empty?
        config.cf_add_resource subnet_group.resource_name, subnet_group
      end
      super(config)
    end

    def resource_name
      resource_style(name) + "RDS"
    end

    def subnet_group
      RDSSubnetGroup.new(self, rds_subnets)
    end

    def db_security_group(name, description, options={}, &block)
      d = RDSSecurityGroup.new(name, description, options.merge(:parent => self), &block)
      db_security_groups << d
      d
    end

    def to_h
      h = {
        "Type" => "AWS::RDS::DBInstance",
        "Properties" => {
          "DBSecurityGroups" => db_security_groups.collect { |g| DrawCloud.ref(g)},
          "AllocatedStorage" => DrawCloud.ref(allocated_storage),
          "Engine" => DrawCloud.ref(engine),
          "DBInstanceClass" => DrawCloud.ref(db_instance_class),
          "MasterUsername" => DrawCloud.ref(master_username),
          "MasterUserPassword" => DrawCloud.ref(master_user_password),
        }
      }
      p = h["Properties"]
      p["DBSnapshotIdentifier"] = DrawCloud.ref(db_snapshot_identifier) if db_snapshot_identifier
      p["MultiAZ"] = multi_az unless multi_az.nil?
      p["EngineVersion"] = DrawCloud.ref(engine_version) unless engine_version.nil?
      p["Iops"] = DrawCloud.ref(iops) if iops
      p["DBSubnetGroupName"] = DrawCloud.ref(subnet_group) unless rds_subnets.empty?
      p["AutoMinorVersionUpgrade"] = DrawCloud.ref(auto_minor_version_upgrade) unless auto_minor_version_upgrade.nil?
      p["BackupRetentionPeriod"] = DrawCloud.ref(backup_retention_period) unless backup_retention_period.nil?
      add_standard_properties(h)
    end
  end
end
