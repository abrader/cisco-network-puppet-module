#
# Manages the version of Cisco Image running on a device.
#
# Copyright (c) 2017 Cisco and/or its affiliates.
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

Puppet::Type.newtype(:cisco_upgrade) do
  @doc = "Manages the version of Cisco Image running on a device.

  ```
  cisco_upgrade {\"<instance_name>\":
    ..attributes..
  }
  ```

  There can only be one instance of cisco_upgrade i.e. 'image'

  Example:
  ```
    cisco_upgrade {'image' :
      version           => '7.0(3)I5(1)',
      source_uri        => 'bootflash:///nxos.7.0.3.I5.1.bin',
      force_upgrade     => false,
      delete_boot_image => false,
    }
  ```
  "

  # Parse out the title to fill in the attributes in these
  # patterns. These attributes can be overwritten later.
  def self.title_patterns
    identity = ->(x) { x }
    patterns = []

    patterns << [
      /^(\S+)$/,
      [
        [:name, identity]
      ],
    ]
    patterns
  end

  newparam(:name, namevar: :true) do
    # Parameter used only to satisfy namevar
    desc 'Name of cisco_upgrade instance. Valid values are string'
    validate do |name|
      warning "only 'image' is accepted as a valid name" if name != 'image'
    end
  end

  newparam(:source_uri) do
    examples = "\nExample:\nbootflash:nxos.7.0.3.I5.2.bin"
    supported = "\nNOTE: Only bootflash: is supported."
    desc "URI to the image to install on the device. Format <uri>:<image>.
          Valid values are string.#{examples}#{supported}"

    validate do |uri|
      fail 'source_uri must match format <uri>:<image>' unless uri[/\S+:\S+/]
    end
    munge do |uri|
      image = {}
      # Convert <uri>:<image> to a hash.
      # The Node-utils API expects uri and image_name as two
      # separate arguments. Pre-processing the arguments here.
      if uri.include?('/')
        image[:uri] = uri.split('/')[0]
        image[:image_name] = uri.split('/')[-1]
      else
        image[:uri] = uri.split(':')[0] + ':'
        image[:image_name] = uri.split(':')[-1]
      end
      image
    end
  end # param source_uri

  newparam(:force_upgrade) do
    desc 'Force upgrade the device.'
    defaultto :false
    newvalues(:true, :false)
  end # param force_upgrade

  newparam(:delete_boot_image) do
    desc 'Delete the booted image(s).'
    defaultto :false
    newvalues(:true, :false)
  end # param delete_boot_image

  ##############
  # Attributes #
  ##############

  newproperty(:version) do
    desc 'Version of the Cisco image to install on the device.
          Valid values are strings'
    validate do |ver|
      fail "Version can't be nil or an empty string" if
        ver == '' || ver.nil? == :true
      valid_chars = 'Version can only have the following
          characters: 0-9, a-z, A-Z, (, ) and .'
      fail "Invalid version string. #{valid_chars}" unless
        (/([0-9a-zA-Z().]*)/.match(ver))[0] == ver
    end
  end # property version
end
