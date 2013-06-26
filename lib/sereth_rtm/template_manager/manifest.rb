# Stores template metadata, including name, path, access rights
#  Extensible for extra meta-tasks
class Sereth::TemplateManager::Manifest
  class << self
    # Load the manifest using the DSL
    def load

    end

    # Parse the raw data, and save the cached entries if required
    def generate(save = false)
      # Code to export into the manifest cache
      export = "Sereth::TemplateManager::Manifest.register(:raw)"

      Dir.glob("app/template/raw/**") do |file|  
        template = Parser.read(file)
        template.raw = file

        if save
          # Store the parsed template to server throuch a controller
          template.cache = "app/template/cache/#{template.name}"
          File.open(template.cache) do |cached_template|
            cached_template.print(template.code)
          end

          # Store the template metadata for serving cached data in production
          File.open("app/template/manifest.rb", "w") do |manifest|  
            manifest.puts(export % {raw: template.metadata})
          end
        end
      end
    end

    # Returns 
    def serve(path)
      inst = @db[path]
      raise "Invalid manifest path [#{path}]" if !inst
      return inst.source
    end

    def parse(path)
      cur_entry = @insts[]
      Context.get(:sprockets).source

    end

    def provides?

    end

  end
end