# The NXAPI provider for snmp group.
#
# February, 2015
# 
# Copyright (c) 2015 Cisco and/or its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'cisco_node_utils' if Puppet.features.cisco_node_utils?

Puppet::Type.type(:cisco_snmp_group).provide(:nxapi) do
  desc "The NXAPI provider for snmp group."

  confine :feature => :cisco_node_utils

  mk_resource_methods

  def self.instances
    group_instances = []
    Cisco::SnmpGroup.groups.each { |id|
      begin
        group_instances << new(
          :name => id,
          :ensure => :present)
      end
    }
    return group_instances
  end

  def self.prefetch(resources)
    group_instances = instances

    resources.keys.each do |name|
      provider = group_instances.find { |group| group.name == name }
      resources[name].provider = provider unless provider.nil?
    end
  end

  def initialize(value={})
    super(value)
    @group = nil
    debug "Created provider instance of cisco_snmp_group."
  end

  def exists?
    if not Cisco::SnmpGroup.exists?(@resource[:group])
      debug "Group instance with name #{@resource[:group]} not found"
      @property_hash[:ensure] = :absent
      return false
    end
    @property_hash[:ensure]  = :present
    @property_hash[:group] = @resource[:group]
    return true
  rescue RuntimeError => e
    fail(e.message)
  end

  def create
    error "Snmp group creation not supported. " +
          "Group #{@resource[:group]} not created."
  end

  def destroy
    error "Snmp group deletion not supported. " +
          "Group #{@resource[:group]} not deleted."
  end

end
