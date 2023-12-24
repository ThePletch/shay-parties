# helpful functions for debugging and exploration

module CoreExtensions
  module ConsoleMethods
    def unique_methods(thing)
      (thing.public_methods - Object.public_methods).sort
    end
  end
end
