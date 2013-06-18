module DrawCloud
  class NetworkAclEntry < Base
    def self.entries_from_spec(action, protocol_spec, direction, cidr, ports_or_types_spec, options={}, &block)
      protocol = case protocol_spec
                 when :everything, :any, :all
                   -1
                 when :icmp
                   1
                 when :tcp
                   6
                 when :udp
                   17
                 when Numeric
                   protocol_spec
                 else
                   raise ArgumentError, "Unknown protocol description #{protocol_spec.inspect}"
                 end
      
      raise ArgumentError, "Unknown ACL direction #{direction.inspect}" unless direction == :ingress || direction == :egress

      cidr = "0.0.0.0/0" if :any == cidr

      pts = if -1 == protocol
              [nil]
            elsif 1 == protocol
              if :any == ports_or_types_spec
                [[-1, -1]]
              elsif :echo == ports_or_types_spec
                [[8, 0], [0, 0]]
              else
                raise ArgumentError, "Can't understand ICMP specification #{ports_or_types_spec.inspect} - maybe you need to add this code"
              end
            elsif 6 == protocol || 17 == protocol
              case ports_or_types_spec
              when Numeric
                [ports_or_types_spec]
              when Range
                [[ports_or_types_spec.min, ports_or_types_spec.max]]
              when Array
                ports_or_types_spec.collect {|p| if p.is_a?(Range) then [p.min, p.max] else [p, p] end }
              else
                raise ArgumentError, "Can't understand TCP/UDP port specification #{ports_or_types_spec.inspect} - maybe you need to add this code"
              end
            end

      pts.collect do |s|
        NetworkAclEntry.new(action, protocol, direction, cidr, ports_or_types_spec, options)
      end
    end

    attr_accessor :index, :action, :protocol, :direction, :cidr, :ports
    def initialize(action, protocol, direction, cidr, ports_or_types, options={}, &block)
      @action = action
      @protocol = protocol
      @direction = direction
      @cidr = cidr
      @ports_or_types = ports_or_types
      super(options, &block)
    end

    def outgoing?
      :egress == direction
    end

    def icmp?
      1 == protocol
    end

    def tcp_or_udp?
      6 == protocol || 17 == protocol
    end

    def load_into_config(config)
      config.cf_add_resource resource_name, self
      super(config)
    end

    def resource_name
      DrawCloud.resource_name(network_acl) + direction.to_s.capitalize + "Rule" + index.to_s
    end

    def to_h
      h = {
        "Type" => "AWS::EC2::NetworkAclEntry",
        "Properties" => {
          "RuleNumber" => index,
          "Protocol" => protocol,
          "RuleAction" => case action
                          when :allow
                            "allow"
                          when :deny
                            "deny"
                          else
                            raise ArgumentError, "Unknown NetworkAclEntry action #{action.inspect}"
                          end,
          "Egress" => outgoing?,
          "CidrBlock" => cidr
        }
      }
      h["Properties"]["NetworkAclId"] = DrawCloud.ref(network_acl) if network_acl
      if icmp?
        h["Properties"]["Icmp"] = {"Type" => ports_or_types[0], "Code" => ports_or_types[1] }
      end
      if tcp_or_udp?
        h["Properties"]["PortRange"] = {"From" => ports_or_types[0], "To" => ports_or_types[1] }
      end
      add_standard_properties(h)
    end
  end
end
