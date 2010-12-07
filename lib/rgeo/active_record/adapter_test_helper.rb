# -----------------------------------------------------------------------------
# 
# Helper methods for ActiveRecord adapter tests
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


require 'rgeo/active_record'
require 'yaml'
require 'logger'


module RGeo
  module ActiveRecord
    
    
    # A helper module for creating unit tests for adapters.
    
    module AdapterTestHelper
      
      @class_num = 0
      
      
      def self.included(klass_)
        database_config_ = ::YAML.load_file(klass_.const_get(:DATABASE_CONFIG_PATH)) rescue nil
        if database_config_
          database_config_.symbolize_keys!
          if klass_.respond_to?(:before_open_database)
            klass_.before_open_database(:config => database_config_)
          end
          klass_.const_set(:DATABASE_CONFIG, database_config_)
          ar_class_ = AdapterTestHelper.new_class(database_config_)
          klass_.const_set(:DEFAULT_AR_CLASS, ar_class_)
          if klass_.respond_to?(:initialize_database)
            klass_.initialize_database(:ar_class => ar_class_, :connection => ar_class_.connection)
          end
          def klass_.define_test_methods
            yield
          end
        else
          def klass_.define_test_methods
            def test_warning
              puts "WARNING: Couldn't find database.yml; skipping tests."
            end
          end
        end
      end
      
      
      def self.new_class(param_)
        base_ = param_.kind_of?(::Class) ? param_ : ::ActiveRecord::Base
        config_ = param_.kind_of?(::Hash) ? param_ : nil
        klass_ = ::Class.new(base_)
        @class_num += 1
        self.const_set("Klass#{@class_num}".to_sym, klass_)
        klass_.class_eval do
          establish_connection(config_) if config_
          set_table_name(:spatial_test)
        end
        klass_
      end
      
      
      def setup
        @factory = ::RGeo::Cartesian.preferred_factory(:srid => 4326)
        @geographic_factory = ::RGeo::Geographic.spherical_factory(:srid => 4326)
        cleanup_tables
      end
      
      
      def teardown
        cleanup_tables
      end
      
      
      def cleanup_tables
        klass_ = self.class.const_get(:DEFAULT_AR_CLASS)
        if klass_.connection.tables.include?('spatial_test')
          klass_.connection.drop_table(:spatial_test)
        end
      end
      
      
      def create_ar_class(opts_={})
        @ar_class = AdapterTestHelper.new_class(self.class.const_get(:DEFAULT_AR_CLASS))
      end
      
      
    end
    
    
  end
end
