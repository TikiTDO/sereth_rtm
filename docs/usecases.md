Rails Dev Mode
  - Inject TM initializer into Rails
    + Configures sprockets inst as rails.application.assets
    + Inject template controller into routes (Configurable. Defaults to warn)
    + Inject view helper into general view helper
    + Initialize TM in proper mode for execution
    + Initialize cache
  - Request in development
    + Routed to Template controller
    + Template controller queries TM manifest
      * Get from sprockets if no manifest record (or error if no raw)
      * Match TM manifest record to the sprockets manifest record
      * Try to build if raw was updated
      * Return from file

  - Request in production
    + Routed to Template controller
    + Queries TM Manifest
      * Error if no manifest record(s)
      * Return from cache if available
      * Return from file otherwise (and store to cache)

  - Build request
    + Query every file in the templates directory
    + Save resulting manifest

  - Check request
    + Load Manifest
    + Check file dates/checksums

  - Error Generation
    + Template Phase error: Resulting template is error text/popup
    + Json Phase error: resulting json has the pass flag off, with error data
