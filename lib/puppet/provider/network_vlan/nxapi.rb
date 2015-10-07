$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"..","..",".."))
require 'puppet/type/cisco_vlan'
require 'puppet/provider/cisco_vlan/nxapi'

Puppet::Type.type(:network_vlan).provide(:nxapi, :parent => Puppet::Type.type(:cisco_vlan).provider(:nxapi)) do
  @doc = "cisco VLAN"

  has_features :activable, :describable

  mk_resource_methods

  def self.instances
    vlans = []
    Cisco::Vlan.vlans.each { |vlan_id, v|
      vlan = {
        :id          => vlan_id,
        :name        => vlan_id,
        :vlan_name   => v.send(:vlan_name),
        :shutdown    => v.send(:shutdown),
        :ensure      => :present,
      }
      vlans << new(vlan)
    }
    return vlans
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def flush
    if @property_flush[:ensure] == :absent
      @vlan.destroy
      @vlan = nil
      @property_hash[:ensure] = :absent
    else
      if @property_hash.empty?
        #create a new vlan
        @vlan = Cisco::Vlan.new(@resource[:id])
      end
      #modify vlan properties
      if @resource[:shutdown]
        shutdown = false
        if @resource[:shutdown] == :true
          shutdown = true
        end
        @vlan.shutdown = shutdown if @vlan.shutdown != shutdown
      end
      @vlan.vlan_name = @resource[:vlan_name] if @resource[:vlan_name] && @vlan.vlan_name != @resource[:vlan_name]
    end
  end

end
