You are evaluating a system that takes in 1) a set of instructions for refactoring code and 2) a piece of code to be refactored. Your job is to judge how well that piece of code was refactored based on 3) the code that the system returned, 4) a target value showing desired output and 5) a rubric.

Format your response as a dictionary, where each element of the rubric is a key paired with one value.

## 1) Instructions

These are the instructions provided to the system demonstrating how to refactor a piece of code:

`````
<<system_prompt>>
`````

## 2) Code to be refactored

Here is the code that was refactored:

`````
<<user_prompt>>
`````

## 3) Code that the system returned

Here is the code that the system ultimately returned:

`````
<<assistant_response>>
`````

## 4) Target

The following is a target value to help with grading: 

`````
<<target>>
`````

The target should be used to get a broad sense of what the desired output may look like, but do note that correct solutions may look quite different than the target; this task is sufficiently open-ended such that there any many possible viable solutions. 

## 5) Rubric

The following is the rubric by which you will grade how well the system followed the instructions.

### Function Selection

- `correctness_selection`: For whichever function is relevant, uses one of `c("Yes", "No")`.
    - Transitions stop()/abort() to cli_abort().
    - Transitions warning()/warn() to cli_warn().
    - Transitions message()/inform() to cli_inform().
- `correctness_untouched`: In general, is the previous, compiled verbiage in the message intact? Are the functions, arguments, and variable values referenced in the message the same as they were before? One of `c("Yes", "No")`.

###  Substitution Syntax

- `substitution_sprintf`: Replaces sprintf-style %s with cli substitutions: One of `c("Yes", "No", "NA")`.
- `substitution_paste0`: Transitions paste0() calls to cli substitutions, one of `c("Yes", "No", "NA")`.
- `substitution_glue`: Converts glue::glue() calls to cli substitutions, one of  `c("Yes", "No", "NA")`.

In each of the above `substitution_*` entries, provide a "Yes" if the statement wasn't transitioned to cli substitutions but the target response didn't either.

### Argument Handling

- `args_retained`: Retains existing arguments (call, body, footer, trace, parent, .internal) if present, one of  `c("Yes", "No", "NA")`.
- `args_minimal`: Doesn't add unnecessary arguments, one of  `c("Yes", "No", "NA")`.
- `args_integration`: Effectively incorporates code that lives outside of the call to the condition-raising function into the body of the message as an inline substitution so that there is ultimately only a single call to a `cli_*()` function in the output. One of  `c("Yes", "No", "NA")`.

### Pluralization

- `pluralization_implemented`: Correctly implements pluralization (simple {?s}, irregular `{{?y/ies}}`, or cli::qty()) where appropriate, one of c`("Yes", "No", "NA")`


### Message Structuring

- `structure_vector`: Correctly breaks multi-sentence error messages into character vectors, one of `c("Yes", "No", "NA")`.
- `structure_bullets`: Properly names subsequent elements with "i" = , one of `c("Yes", "No", "NA")`

### Semantic Markup

- `markup_general`: Makes reasonable use of inline semantic markup when it ought to, one of `c("Yes", "No", "NA")`. Note that it's not always obvious which markup ought to be used (.arg vs .cls .vs .code, etc.) without additional context, so it's okay if e.g. .arg is used interchangably with .code or .field—grade "Yes" in that case.
- `markup_fn`: If .fn/.fun is used for function names, is the markup applied correctly? One of `c("Yes", "No", "NA")`. Code should omit parentheses after function names as it's applied automatically: for example, use `{{.fun mutate}}` or `{{.fun {{fn}}}}` rather than `{{.fun mutate()}}` or `{{.fun {{fn}}()}}`.
- `markup_friendly`: When describing what was _actually_ passed, was code transitioned to use `.obj_type_friendly`? One of `c("Yes", "No", "NA")`.

Again, format your response as a dictionary, where each element of the rubric is a key paired with one value. For example, an output that does everything right but doesn't need to apply all of the refactorings in the rubric might look like:

```
{{
  "correctness_selection": "Yes",
  "correctness_untouched": "Yes",
  "substitution_sprintf": "Yes",
  "substitution_paste0": "Yes",
  "substitution_glue": "NA",
  "args_retained": "Yes",
  "args_minimal": "Yes",
  "args_integration": "Yes",
  "pluralization_implemented": "Yes",
  "structure_vector": "Yes",
  "structure_bullets": "Yes",
  "markup_general": "Yes",
  "markup_fn": "NA",
  "markup_friendly": "Yes"
}}
```

The backticks are for demonstration purposes only and ought not to be included in your response.
