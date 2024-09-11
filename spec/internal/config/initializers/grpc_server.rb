# frozen_string_literal: true

::Gruf.interceptors.clear

::Gruf.configure do |c|
  c.server_binding_url = "0.0.0.0:3009"
  c.logger = Rails.logger
end

Rails.root.glob("pkg/server/**/*_services_pb.rb").sort.each { require _1 }
Rails.root.glob("app/rpc/**/*.rb").sort.each { require _1 }
