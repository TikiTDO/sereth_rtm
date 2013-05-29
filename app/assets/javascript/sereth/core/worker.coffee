class sereth.worker
  getContext: () -> 

  if (typeof(Worker) == 'undefined')

    # No worker available. Use some sort of hack
  else
    # 