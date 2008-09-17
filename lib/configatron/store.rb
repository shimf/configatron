class Configatron
  class Store
    
    # Takes an optional Hash of parameters
    def initialize(options = {})
      @_store = {}
      configure_from_hash(options)
    end
    
    # Returns a Hash representing the configurations
    def to_hash
      @_store
    end

    def inspect # :nodoc:
      to_hash.inspect
    end

    # Allows for the configuration of the system via a Hash
    def configure_from_hash(options)
      parse_options(options)
    end

    # Allows for the configuration of the system from a YAML file.
    # Takes the path to the YAML file.
    def configure_from_yaml(path)
      begin
        configure_from_hash(YAML.load(File.read(path)))
      rescue Errno::ENOENT => e
        puts e.message
      end
    end

    # Returns true if there are no configuration parameters
    def nil?
      return @_store.empty?
    end

    # Retrieves a certain parameter and if that parameter
    # doesn't exist it will return the default_value specified.
    def retrieve(name, default_value = nil)
      @_store[name.to_sym] || default_value
    end
    
    # Removes a parameter. In the case of a nested parameter
    # it will remove all below it.
    def remove(name)
      @_store.delete(name.to_sym)
    end

    # Sets a 'default' value. If there is already a value specified
    # it won't set the value.
    def set_default(name, default_value)
      unless @_store[name.to_sym]
        @_store[name.to_sym] = parse_options(default_value)
      end
    end
    
    def method_missing(sym, *args) # :nodoc:
      if sym.to_s.match(/(.+)=$/)
        @_store[sym.to_s.gsub("=", '').to_sym] = parse_options(*args)
      elsif @_store.has_key?(sym)
        return @_store[sym]
      else
        store = Configatron::Store.new
        @_store[sym] = store
        return store
      end
    end
    
    def ==(other) # :nodoc:
      self.to_hash == other
    end
    
    # = DeepClone
    #
    # == Version
    #  1.2006.05.23 (change of the first number means Big Change)
    #
    # == Description
    #  Adds deep_clone method to an object which produces deep copy of it. It means
    #  if you clone a Hash, every nested items and their nested items will be cloned.
    #  Moreover deep_clone checks if the object is already cloned to prevent endless recursion.
    #
    # == Usage
    #
    #  (see examples directory under the ruby gems root directory)
    #
    #   require 'rubygems'
    #   require 'deep_clone'
    #
    #   include DeepClone
    #
    #   obj = []
    #   a = [ true, false, obj ]
    #   b = a.deep_clone
    #   obj.push( 'foo' )
    #   p obj   # >> [ 'foo' ]
    #   p b[2]  # >> []
    #
    # == Source
    # http://simplypowerful.1984.cz/goodlibs/1.2006.05.23
    #
    # == Author
    #  jan molic (/mig/at_sign/1984/dot/cz/)
    #
    # == Licence
    #  You can redistribute it and/or modify it under the same terms of Ruby's license;
    #  either the dual license version in 2003, or any later version.
    #
    def deep_clone( obj=self, cloned={} )
      if cloned.has_key?( obj.object_id )
        return cloned[obj.object_id]
      else
        begin
          cl = obj.clone
        rescue Exception
          # unclonnable (TrueClass, Fixnum, ...)
          cloned[obj.object_id] = obj
          return obj
        else
          cloned[obj.object_id] = cl
          cloned[cl.object_id] = cl
          if cl.is_a?( Hash )
            cl.clone.each { |k,v|
              cl[k] = deep_clone( v, cloned )
            }
          elsif cl.is_a?( Array )
            cl.collect! { |v|
              deep_clone( v, cloned )
            }
          end
          cl.instance_variables.each do |var|
            v = cl.instance_eval( var )
            v_cl = deep_clone( v, cloned )
            cl.instance_eval( "#{var} = v_cl" )
          end
          return cl
        end
      end
    end
    
    private
    def parse_options(options)
      if options.is_a?(Hash)
        options.each do |k,v|
          if v.is_a?(Hash)
            self.method_missing(k.to_sym).configure_from_hash(v)
          else
            self.method_missing("#{k.to_sym}=", v)
          end
        end
      else
        return options
      end
    end
    
  end
end