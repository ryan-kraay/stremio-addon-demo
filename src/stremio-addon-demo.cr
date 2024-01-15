require "kemal"
require "stremio-addon-devkit/api/manifest_handler"
require "stremio-addon-devkit/conf"

module Stremio::Addon::Demo
  VERSION = "0.1.0"

  # TODO: Put your code here
end

alias DevKit = Stremio::Addon::DevKit

# Construct a manifest to tell our client what features we support
manifest = DevKit::Conf::Manifest.build(
  id: "io.github.ryan-kraay.stremio-addon-demo",
  name: "CrystalDemo",
  description: "A demo powered by https://github.com/ryan-kraay/stremio-addon-devkit",
  version: "0.0.1") do |conf|
  conf.catalogs << DevKit::Conf::Catalog.new(
      type: DevKit::Conf::ContentType::Movie,
      id: "movies4u",
      name: "Movies for you")
end

# Now we create a router, this will allow us to assign
# generated REST endpoint (defined in the manifest) with
# callbacks
router = DevKit::Api::ManifestHandler.new
# Register the router with kemal
add_handler router

# This is our callback, it will be executed for each request
def catalog_movies(env, addon)
#def catalog_movies(env : HTTP::Server::Context,addon : DevKit::Api::CatalogMovieRequest) : DevKit::Api::CatalogMovieResponse?
  # TODO:  Add your code here
  DevKit::Api::CatalogMovieResponse.build do |catalog|
    catalog.metas << DevKit::Api::CatalogMovieResponse::Meta.new(
        type: DevKit::Conf::ContentType::Movie,
        id: "tt0032138",
        name: "The Wizard of Oz",
        poster: URI.parse("https://images.metahub.space/poster/medium/tt0032138/img")
        )
  end
end

# Bind our manifest to a series of callback
# (there are many ways to do this)
router.bind(manifest) do |callback|
  callback.catalog_movie &->catalog_movies(HTTP::Server::Context, DevKit::Api::CatalogMovieRequest)
  #callback.catalog_movie &->catalog_movies
end

# Useful for health checks
get "/alive" do
  "yes"
end

# Render.io and other platforms use PORT to decide what port the application
# should use
Kemal.config.port = ENV.fetch("PORT", "8080").to_i
Kemal.run
