The `inst/` directory contains source code and intermediate results for other components of the eval:

-   `inst/dataset/` contains the app that was used to generate the source data underlying `chores_dataset` as well as the prompt that generated the app. The app writes `.json` files that are ultimately loaded into R and concatenated into `chores_dataset`.

-   `inst/results` contains the logs resulting from running the eval using a given model; `inst/results/tasks` contains the vitals Tasks as `.rda`, `inst/results/logs` contains the `.json` logs generated from the Tasks.
