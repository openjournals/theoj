require 'rack/streaming_proxy'

Theoj::Application.configure do
  # Will be inserted at the end of the middleware stack by default.
  config.middleware.use Rack::StreamingProxy::Proxy do |request|

    # Inside the request block, return the full URI to redirect the request to,
    # or nil/false if the request should continue on down the middleware stack.
    if request.path.start_with?('/proxy')
      request.params["url"]
    end
  end
end
