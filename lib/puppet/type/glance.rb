Puppet::Type.newtype(:glance) do
  @doc = "Manage openstack glance images: http://glance.openstack.org/

    This allows management of openstack compatible VM images and meta data.
    This resource will only manage images on the puppet node, and it cannot
    verify the image, only the image name, so once an image is uploaded it 
    will only modify the metadata and not the actual image. This limitation
    is because we have no accurate metadata to detect changes."

  ensurable do
    desc "Add or delete images from glance server."

    defaultto(:present)

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:name, :namevar=>true) do
    desc "The VM image name."
  end

  newproperty(:id) do
    desc "The VM image id, this is not a parameter the user should set."
  end

  #public clashes with ruby public
  newproperty(:public) do
    desc "Is the VM public."

    # The output is Yes, No
    newvalues(/^Yes|No$/)

    defaultto "Yes"
  end

  newproperty(:disk) do
    desc "The VM image disk format."

    newvalues(/^raw|vhd|vmdk|vdi|iso|qcow2|aki|ari|ami$/)
  end

  newproperty(:container) do
    desc "The VM image container format."

    newvalues(/^ovf|bare|aki|ari|ami$/)
  end

  newproperty(:location) do
    desc "The VM image location, only specify for http."
  end

  newparam(:image) do
    desc "The VM image file on local filesystem."

    # must present absolute path to file.
    newvalues(/^\//)
  end

  newproperty(:size) do
    desc "The VM image size, may use this to update image."
  end
end
