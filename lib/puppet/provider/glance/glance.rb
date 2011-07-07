Puppet::Type.type(:glance).provide(:glance) do
  @doc = "Manages glance images via glance cli. I suppose someone can implement
    another version using the REST api."

  # This is to mask the default provider which allows glance installation and management in a single puppet run.
  confine :feature => :posix
  defaultfor :feature => :posix

  commands :glance => "glance"

  @glance

  def self.instances
    unless @glance
      self.cache
    end

    # we only need to implement parameters since puppet will check properties
    @glance.collect{ |name, value|
      new(:name=>name, :id=>value["Id"])
    }
  end

  def self.cache(*lookup)
    @glance ||= {}

    # retreive list of image ids with glance index.
    if lookup == []
      Puppet.debug "Puppet::Provider::Glance: creating cache of all vm instances."
      image_ids = glance('index').split("\n").collect { |line|
        $1 if line =~ %r(^(\d+)\s+\S+)
      }.compact!
    else
      Puppet.debug "Puppet::Provider::Glance: reloading cache of vm instances #{lookup}."
      image_ids = lookup
    end

    # retrieve detail information for each image id
    image_ids.each do |id|

      # creating hash from glance show output:
      #
      # $ glance show 1
      # URI: http://0.0.0.0/images/1
      # Id: 1
      # Public: Yes
      # Name: ramdisk
      # Size: 5882349
      # Location: file:///var/lib/glance/images/1
      # Disk format: ari
      # Container format: ari
      results = Hash[ *glance('show',id).split("\n").collect { |line|
        val = line.split(":",2)
        [val[0].to_s, val[1].to_s.strip]
      }.flatten ]

      name=results["Name"]
      results.delete "Name"
      @glance[name] = results
    end

    Puppet.debug "Puppet::Provider::Glance: \n"+@glance.inspect
  end

  def self.cache_delete(lookup)
    @glance.delete(lookup)
  end

  def self.vm(lookup)
    # This results in two lookups if a resource does not exists but it's necessary
    unless @glance and @glance[lookup]
      self.cache
    end

    @glance[lookup]
  end

  # not sure if this is necessary since everything should call self.class.vm
  def vm(lookup)
    self.class.vm(lookup)
  end

  def cache_reload(lookup)
    self.class.cache(lookup)
  end

  def cache_delete(lookup)
    self.class.cache_delete(lookup)
  end

  def id
    vm(resource[:name])["Id"]
  end

  def public
    # currently not able to detect non public instances
    "Yes"
  end

  def public=(val)
    # currently not able to detect non public instances
    updatevm
  end

  def disk
    vm(resource[:name])["Disk format"]
  end

  def disk=(val)
    updatevm
  end

  def container
    vm(resource[:name])["Container format"]
  end

  def container=(val)
    updatevm
  end

  def location
    vm(resource[:name])["Location"]
  end

  def location=(val)
    updatevm
  end

  def size
    vm(resource[:name])["Size"]
  end

  # size is not set manually, so no size=

  def create
    Puppet.debug("Puppet::Provider::Glance: creating glance image #{resource[:name]}")

    if resource[:image]
      raise Puppet::Error, "Failed to locate glance image #{resource[:image]}" unless File.exists?resource[:image]
    end

    # generate all options and ensure public is Yes.
    opt = [resource[:name]      ? "name=\"#{resource[:name]}\""             : nil,
           resource[:public]    ? "is_public=true"                          : nil,
           resource[:disk]      ? "disk_format=#{resource[:disk]}"          : nil,
           resource[:container] ? "container_format=#{resource[:container]}": nil,
           resource[:location]  ? "location=#{resource[:location]}"         : nil,
           resource[:image]     ? "< #{resource[:image]}"                   : nil]

    # unfortunately we can't use glance(..) because it doesn't handle the redirection < ... 
    #glance("add", opt.compact)

    command = "glance add #{opt.compact.join(" ")}"

    Puppet.debug("Puppet::Provider::Glance: executing #{command}")
    Kernel.system command
  end

  def destroy
    Puppet.debug("Puppet::Provider::Glance: destroying glance image #{resource[:name]}")
    res = vm(resource[:name])

    if res and res["Id"]
      glance("delete", res["Id"])

      # This flushes the cache otherwise deleting the resource won't be reflected.
      cache_delete(resource[:name])
    else
      raise Puppet::Error, "Failed to destroy non-existent instance."
    end
  end

  def updatevm
    unless @update
      Puppet.debug("Puppet::Provider::Glance: updating glance image #{resource[:name]}")

      @update = true
      resource[:disk]      ||= disk
      resource[:container] ||= container
      resource[:location]  ||= location

      opt = [ vm(resource[:name])["Id"],
              resource[:disk]      ? "disk_format=#{resource[:disk]}"          : nil,
              resource[:container] ? "container_format=#{resource[:container]}": nil,
              resource[:location]  ? "location=#{resource[:location]}"         : nil ]

      # Currently do not modify is_public since we can no longer find image via CLI.
      glance("update", opt.compact)

      # This updates the cache otherwise changes to the resource won't be reflected.
      cache_reload(id)
    end
  end

  def exists?
    vm(resource[:name])
  end
end
