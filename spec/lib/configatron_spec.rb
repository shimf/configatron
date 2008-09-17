require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe "configatron" do

  before(:each) do
    configatron.reset!
  end
  
  describe 'temp' do
    
    it 'should revert back to the original parameters when the block ends' do
      configatron.one = 1
      configatron.letters.a = 'A'
      configatron.letters.b = 'B'
      configatron.temp do
        configatron.letters.b = 'bb'
        configatron.letters.c = 'c'
        configatron.one.should == 1
        configatron.letters.a.should == 'A'
        configatron.letters.b.should == 'bb'
        configatron.letters.c.should == 'c'
      end
      configatron.one.should == 1
      configatron.letters.a.should == 'A'
      configatron.letters.b.should == 'B'
      configatron.letters.c.should be_nil
    end
    
    it 'should take an optional hash of parameters' do
      configatron.one = 1
      configatron.letters.a = 'A'
      configatron.letters.b = 'B'
      configatron.temp(:letters => {:b => 'bb', :c => 'c'}) do
        configatron.one.should == 1
        configatron.letters.a.should == 'A'
        configatron.letters.b.should == 'bb'
        configatron.letters.c.should == 'c'
      end
      configatron.one.should == 1
      configatron.letters.a.should == 'A'
      configatron.letters.b.should == 'B'
      configatron.letters.c.should be_nil
    end
    
  end

  describe 'configure_from_hash' do
    
    it 'should configure itself from a hash' do
      configatron.foo.should be_nil
      configatron.configure_from_hash(:foo => :bar)
      configatron.foo.should == :bar
    end
    
    it 'should handled deeply nested params' do
      configatron.friends.rachel.should be_nil
      configatron.configure_from_hash(:friends => {:rachel => 'Rachel Green'})
      configatron.friends.rachel.should == 'Rachel Green'
    end
    
    it 'should not remove previously defined params' do
      configatron.friends.rachel = 'Rachel Green'
      configatron.friends.ross = 'Ross Gellar'
      configatron.friends.monica = 'Monica Gellar'
      configatron.configure_from_hash(:friends => {:rachel => 'R. Green', :monica => 'Monica Bing'})
      configatron.friends.ross.should == 'Ross Gellar'
      configatron.friends.rachel.should == 'R. Green'
      configatron.friends.monica.should == 'Monica Bing'
    end 
    
  end
  
  describe 'configure_from_yaml' do
    
    it 'should configure itself from a yaml file' do
      configatron.futurama.should be_nil
      configatron.configure_from_yaml(File.join(File.dirname(__FILE__), 'futurama.yml'))
      configatron.futurama.robots.bender.should == 'Bender The Robot'
    end
    
    it 'should not remove previously defined params' do
      configatron.futurama.mutants.leela = 'Leela'
      configatron.configure_from_yaml(File.join(File.dirname(__FILE__), 'futurama.yml'))
      configatron.futurama.robots.bender.should == 'Bender The Robot'
      configatron.futurama.mutants.leela = 'Leela'
    end
    
    it "should fail silently if the file doesn't exist" do
      lambda{configatron.configure_from_yaml('i_dont_exist.yml')}.should_not raise_error
    end
    
  end
  
  it 'should return a parameter' do
    configatron.foo = :bar
    configatron.foo.should == :bar
  end
  
  it 'should return a nested parameter' do
    configatron.children.dylan = 'Dylan Bates'
    configatron.children.dylan.should == 'Dylan Bates'
  end
  
  it 'should set a nested parameter and not remove previously defined params' do
    configatron.friends.rachel = 'Rachel Green'
    configatron.friends.rachel.should == 'Rachel Green'
    configatron.friends.ross = 'Ross Gellar'
    configatron.friends.ross.should == 'Ross Gellar'
    configatron.friends.monica = 'Monica Gellar'
    configatron.friends.monica.should == 'Monica Gellar'
    configatron.friends.rachel = 'R. Green'
    configatron.friends.monica = 'Monica Bing'
    configatron.friends.rachel.should == 'R. Green'
    configatron.friends.ross.should == 'Ross Gellar'
    configatron.friends.monica.should == 'Monica Bing'
  end
  
  it 'should return the Configatron instance' do
    configatron.should be_is_a(Configatron)
  end
  
  describe 'to_hash' do
    
    it 'should return a hash of all the params' do
      configatron.one = 1
      configatron.letters.a = 'A'
      configatron.letters.b = 'B'
      configatron.to_hash.should == {:one => 1, :letters => {:a => 'A', :b => 'B'}}
    end
    
  end
  
  describe 'inspect' do
    
    it 'should call return the inspect method of the to_hash method' do
      configatron.one = 1
      configatron.letters.a = 'A'
      configatron.letters.b = 'B'
      configatron.inspect.should == {:one => 1, :letters => {:a => 'A', :b => 'B'}}.inspect
    end
    
  end
  
  describe 'nil?' do
    
    it 'should return true if there are no parameters' do
      configatron.should be_nil
      configatron.friends.should be_nil
    end
    
    it 'should return true if there are no parameters on a nested parameter' do
      configatron.friends.monica.should be_nil
    end
    
  end
  
  describe 'retrieve' do
    
    it 'should retrieve a parameter' do
      configatron.office = 'Michael'
      configatron.retrieve(:office).should == 'Michael'
    end
    
    it 'should return the optional second parameter if the config setting is nil' do
      configatron.retrieve(:office, 'Stanley').should == 'Stanley'
    end
    
    it 'should work with a symbol or a string' do
      configatron.office = 'Michael'
      configatron.retrieve(:office).should == 'Michael'
      configatron.retrieve('office').should == 'Michael'
    end
    
    it 'should work on nested parameters' do
      configatron.the.office = 'Michael'
      configatron.the.retrieve(:office).should == 'Michael'
      configatron.the.retrieve('office').should == 'Michael'
    end
    
  end
  
  describe 'remove' do
    
    it 'should remove a parameter' do
      configatron.movies = 'Pulp Fiction'
      configatron.movies.should == 'Pulp Fiction'
      configatron.remove(:movies)
      configatron.movies.should be_nil
    end
    
    it 'should remove a nested parameter' do
      configatron.the.movies = 'Pulp Fiction'
      configatron.the.movies.should == 'Pulp Fiction'
      configatron.the.remove(:movies)
      configatron.the.movies.should be_nil
    end
    
    it 'should work with a symbol or a string' do
      configatron.the.movies = 'Pulp Fiction'
      configatron.the.office = 'Michael'
      configatron.the.remove(:movies)
      configatron.the.movies.should be_nil
      configatron.the.remove('office')
      configatron.the.office.should be_nil
    end
    
    it 'should remove all sub-parameters' do
      configatron.the.movies = 'Pulp Fiction'
      configatron.the.office = 'Michael'
      configatron.remove(:the)
      configatron.the.should be_nil
      configatron.the.movies.should be_nil
    end
    
  end
  
  describe 'set_default' do
    
    it 'should set a default parameter value' do
      configatron.set_default(:movies, 'Pulp Fiction')
      configatron.movies.should == 'Pulp Fiction'
    end
    
    it 'should set a default parameter value for a nested parameter' do
      configatron.the.set_default(:movies, 'Pulp Fiction')
      configatron.the.movies.should == 'Pulp Fiction'
    end
    
    it 'should not set the parameter if it is already set' do
      configatron.movies = 'Transformers'
      configatron.set_default(:movies, 'Pulp Fiction')
      configatron.movies.should == 'Transformers'
    end
    
    it 'should not set the nested parameter if it is already set' do
      configatron.the.movies = 'Transformers'
      configatron.the.set_default(:movies, 'Pulp Fiction')
      configatron.the.movies.should == 'Transformers'
    end
    
  end
  
  describe 'reset!' do
    
    it 'should clear out all parameter' do
      configatron.one = 1
      configatron.letters.a = 'A'
      configatron.letters.b = 'B'
      configatron.one.should == 1
      configatron.letters.a.should == 'A'
      configatron.reset!
      configatron.one.should be_nil
      configatron.letters.a.should be_nil
    end
    
  end

end
