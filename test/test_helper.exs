Application.ensure_all_started(:mimic)

Mimic.copy(ExForger.Test.Repo)
ExUnit.start()
