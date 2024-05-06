# frozen_string_literal: true

Sbmt::App::Gruf::Server.configure!(pool_keep_alive: 1)
Sbmt::App::Grpc.load_server_packages
