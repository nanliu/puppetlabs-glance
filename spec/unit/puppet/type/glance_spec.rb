require 'puppet'
require 'puppet/type/glance'

describe Puppet::Type.type(:glance) do
  before :each do
    @glance = Puppet::Type.type(:glance).new(:name => 'foo', :disk => 'ami', :container => 'ami')
  end

  it 'should accept a image name' do
    @glance[:name] = 'centos'
    @glance[:name].should == 'centos'
  end

  it 'should accept a disk format' do
    @glance[:disk] = 'ari'
    @glance[:disk].should == 'ari'
  end

  it 'should accept a container format' do
    @glance[:container] = 'ari'
    @glance[:container].should == 'ari'
  end

  it 'should require a name' do
    expect { Puppet::Type.type(:glance).new({}) }.should raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'should not allow unknown disk format' do
    expect {  @glance[:disk] = 'bar' }.should raise_error(Puppet::Error, /Valid values match/)
  end

  it 'should not allow unknown container format' do
    expect {  @glance[:container] = 'bar' }.should raise_error(Puppet::Error, /Valid values match/)
  end

  ['raw','vhd','vmdk','vdi','iso','qcow2','aki','ari','ami'].each do |val|
    it "should accept disk property #{val}" do
      @glance[:disk] = val
      @glance[:disk].should == val.to_s
    end
  end

  ['ovf','bare','aki','ari','ami'].each do |val|
    it "should accept container property #{val}" do
      @glance[:container] = val
      @glance[:container].should == val.to_s
    end
  end
end
