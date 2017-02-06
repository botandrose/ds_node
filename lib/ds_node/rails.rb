require "rails"
require "ds_node/ds_resource"

module DSNode
  class Rails < ::Rails::Engine
    initializer "wire up active record macros" do
      ActiveRecord::Base.send :include, DSNode::DSResource
    end
  end
end

