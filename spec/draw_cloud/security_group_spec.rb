require 'spec_helper'

describe DrawCloud::SecurityGroup do
  subject { DrawCloud::SecurityGroup.new(:test, "Test Security Group") }

  it "should be a SecurityGroup" do
    expect(subject).to be_an_instance_of DrawCloud::SecurityGroup
  end

  it "returns itself when asked for the security group" do
    expect(subject).to respond_to :security_group
    expect(subject.security_group).to equal subject
  end

  describe "allow_security_group_in" do
    before :each do
      subject.ingress_rules = []
    end

    let(:protocol) { :tcp }
    let(:security_group_id) { { "Ref" => "AppSecurityGroup" } }
    let(:from_port) { 80 }
    let(:to_port) { 443 }

    it "should add an appropriate ingress rule" do
      subject.allow_security_group_in(protocol, security_group_id, from_port, to_port)
      expect(subject.ingress_rules).to_not be_empty
      expect(subject.ingress_rules.first).to eq({"IpProtocol"=>"tcp",
                                                  "SourceSecurityGroupId"=>{"Ref"=>"AppSecurityGroup"},
                                                  "FromPort"=>"80",
                                                  "ToPort"=>"443"})
    end

  end

  describe "allow_cidr_in" do
    before :each do
      subject.ingress_rules = []
    end

    let(:protocol) { :tcp }
    let(:cidr) { "0.0.0.0/0" }
    let(:from_port) { 80 }
    let(:to_port) { 443 }

    it "should add an appropriate ingress rule" do
      subject.allow_cidr_in(protocol, cidr, from_port, to_port)
      expect(subject.ingress_rules).to_not be_empty
      expect(subject.ingress_rules.first).to eq({"IpProtocol"=>"tcp",
                                                  "CidrIp"=>"0.0.0.0/0",
                                                  "FromPort"=>"80",
                                                  "ToPort"=>"443"})
    end

  end

  describe "provides"
  describe "consumes"

  describe "resource_name" do
    it "returns a styled name with SecurityGroup appended" do
      expect(subject.resource_name).to match(/TestSecurityGroup/)
    end
  end

  describe "check_validity" do
    before :each do
      subject.description = "Test Security Group"
    end

    it "should check validity" do
      subject.description = '~`&&&%'
      expect { subject.to_h }.to raise_error ArgumentError
    end
  end

  describe "to_h" do
    it "should turn itself into a hash" do
      expect(subject.to_h).to be_an_instance_of Hash
    end

    it "should have a type key matching AWS::EC2::SecurityGroup" do
      expect(subject.to_h['Type']).to match(/AWS::EC2::SecurityGroup/)
    end
  end
end
