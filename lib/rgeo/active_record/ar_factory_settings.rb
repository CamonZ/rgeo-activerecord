# -----------------------------------------------------------------------------
# 
# Mysqlgeo adapter for ActiveRecord
# 
# -----------------------------------------------------------------------------
# Copyright 2010 Daniel Azuma
# 
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of the copyright holder, nor the names of any other
#   contributors to this software, may be used to endorse or promote products
#   derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
# -----------------------------------------------------------------------------
;


require 'active_record'


module ActiveRecord
  
  
  # RGeo extends ActiveRecord::Base to include the following new class
  # attributes. These attributes are inherited by subclasses, and can
  # be overridden in subclasses.
  # 
  # === ActiveRecord::Base::rgeo_factory_generator
  # 
  # The value of this attribute is a RGeo::Feature::FactoryGenerator
  # that is used to generate the proper factory when loading geometry
  # objects from the database. For example, if the data being loaded
  # has M but not Z coordinates, and an embedded SRID, then this
  # FactoryGenerator is called with the appropriate configuration to
  # obtain a factory with those properties. This factory is the one
  # associated with the actual geometry properties of the ActiveRecord
  # object. The result of this generator can be overridden by setting
  # an explicit factory for a given class and column using the
  # column_rgeo_factory method.
  
  class Base
    
    
    class_attribute :rgeo_factory_generator, :instance_writer => false
    self.rgeo_factory_generator = nil
    
    
    class << self
      
      
      # This is a convenient way to set the rgeo_factory_generator by
      # passing a block.
      
      def to_generate_rgeo_factory(&block_)
        self.rgeo_factory_generator = block_
      end
      
      
      # Set a specific factory for this ActiveRecord class and the given
      # column name. This setting, if present, overrides the result of the
      # rgeo_factory_generator.
      
      def set_rgeo_factory_for_column(column_, factory_)
        @rgeo_factory_for_column = {} unless defined?(@rgeo_factory_for_column)
        @rgeo_factory_for_column[column_.to_sym] = factory_
      end
      
      
      # Returns the factory generator or specific factory to use for this
      # ActiveRecord class and the given column name.
      # If an explicit factory was set for the given column, returns it.
      # Otherwise, if a params hash is given, passes that has to the
      # rgeo_factory_generator for this class, and returns the resulting
      # factory. Otherwise, if no params hash is given, just returns the
      # rgeo_factory_generator for this class.
      
      def rgeo_factory_for_column(column_, params_=nil)
        @rgeo_factory_for_column = {} unless defined?(@rgeo_factory_for_column)
        result_ = @rgeo_factory_for_column[column_.to_sym] || rgeo_factory_generator || ::RGeo::ActiveRecord::DEFAULT_FACTORY_GENERATOR
        if params_ && !result_.kind_of?(::RGeo::Feature::Factory::Instance)
          result_ = result_.call(params_)
        end
        result_
      end
      
      
    end
    
  end
  
  
end
