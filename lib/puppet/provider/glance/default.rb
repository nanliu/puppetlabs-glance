Puppet::Type.type(:glance).provide(:default) do
  @doc = "stub provider to give an oppurtunity to load glance."

  def self.instances
    {}
  end

  def create
    error
  end

  def destroy
    error
  end

  def exists?
    error
  end

  def error
    fail('Stub provider for glance should not be be invoked.')
  end
end
