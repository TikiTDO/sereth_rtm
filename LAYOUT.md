# Sereth JSON Spec Code Layout

* lib/json_spec
  - json_spec_module.rb:

    The modules that must be *prepended* to enable json_specs for a class. 

    Extends the class with the entry function, a spec enumerator and schema generator entry
    points. Also provides a path name to be used when storing specs.

    Injects the instance to_json and as_json methods.

    Calls out to JsonSpecGenerator in order to create a new spec.

    Calls out to JosnSpecData in order to utilize existing specs.

  - json_spec_generator.rb:

    Context class used to provide the json_spec DSL during spec generation.

    Provides commands if!, override!, extends!. All other method calls evaluate to node
    names, and are used to populate the JsonSpecData instance for this generator.

    Calls out to JsonSpec data in order to sotre configured data nodes, and to retrieve
    previously configured data nodes for extension.

  - json_spec_data.rb

    Storage class used to store all top-level instances of the configured specs, and to 
    utilize this data to generate json from an object, or update and object from json.

    Provides special mechanism for preparing generator commands and raw nodes for export and
    import. Also performs actual export and import using the prepared resources.

    Uses function definition for generating export handlers. Functions have access
    to the context of the function generator which stores the name and subnode information, 
    and perform better than hashes.

    Uses a standard hash map for import handlers. Hash map provides finer level of control at
    the expense of speed. This may be necessary since imported data may be provided by user.

    Calls out to JsonSpecExports in order to generate proc objects used for exports.

    Calls out to JsonSpecImports in order to generate proc objects used for imports.