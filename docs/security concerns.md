Using contexts may cause problems due to thread data sharing. Ensure context
data is cleared before requests.

For now just add a before filter to wipe the context