require 'puppet'
require 'mocha'

RSpec.configure do |config|
  config.mock_with :mocha
end
provider_class = Puppet::Type.type(:glance).provider(:glance)
describe provider_class do

  before :each do
    @class = Class.new(provider_class)
    @resource = Puppet::Type.type(:glance).new({:name => 'centos', :disk => 'aki', :container => 'aki'})
    @provider = @class.new(@resource)
  end

  it 'should cache vm image attributes' do
    @class.expects(:glance).with('index').returns <<-EOT
Found 1 public images...
ID               Name                           Disk Format          Container Format     Size          
---------------- ------------------------------ -------------------- -------------------- --------------
1                centos                         ami                  ami                         5882349

EOT
    @class.expects(:glance).with('show','1').returns <<-EOT
URI: http://0.0.0.0/images/1
Id: 1
Public: Yes
Name: centos
Size: 5882349
Location: file:///var/lib/glance/images/1
Disk format: ami
Container format: ami
EOT
    @provider.name
    @provider.id
    @provider.disk
    @provider.container
    @provider.size
    @provider.location
  end

  it 'should detect vm image attributes' do
    @class.expects(:glance).with('index').returns <<-EOT
Found 1 public images...
ID               Name                           Disk Format          Container Format     Size          
---------------- ------------------------------ -------------------- -------------------- --------------
1                centos                         ami                  ami                         5882349

EOT
    @class.expects(:glance).with('show','1').returns <<-EOT
URI: http://0.0.0.0/images/1
Id: 1
Public: Yes
Name: centos
Size: 5882349
Location: file:///var/lib/glance/images/1
Disk format: ami
Container format: ami
EOT
    @class.cache
    @provider.exists?.should == {"Container format"=>"ami",
        "URI"=>"http://0.0.0.0/images/1",
        "Public"=>"Yes",
        "Location"=>"file:///var/lib/glance/images/1",
        "Size"=>"5882349",
        "Id"=>"1",
        "Disk format"=>"ami"}
  end

  it 'should not match if no images on system' do
    @class.cache
    @class.expects(:glance).with('index').returns <<-EOT
Found 0 public images...
EOT
    @provider.exists?.should be_nil
  end

  it 'should not match if no matching images on system' do
    @class.cache
    @class.expects(:glance).with('index').returns <<-EOT
Found 1 public images...
ID               Name                           Disk Format          Container Format     Size          
---------------- ------------------------------ -------------------- -------------------- --------------
1                ubuntu                         ami                  ami                         5882349
EOT
    @class.expects(:glance).with('show','1').returns <<-EOT
URI: http://0.0.0.0/images/1
Id: 1
Public: Yes
Name: ubuntu
Size: 5882349
Location: file:///var/lib/glance/images/1
Disk format: ami
Container format: ami
EOT
    @provider.exists?.should be_nil
  end

end
