---
layout: post
title: Executing Structured A.I. Workflows with Shopify Roast
date: 2025-05-10 01:00:00
tags: [ai, tools, shopify]
comments: true
---
Last week, my team at Shopify released a new tool called [Roast](https://github.com/Shopify/roast/), a convention-oriented framework for creating structured AI workflows. Our vision is to enable A.I. agents to solve developer productivity problems at scale. Imagine continuously improving unit tests, or optimizing test performance across hundreds of thousands of tests with minimal human intervention!

As we embarked on this journey, we quickly learned that, like many junior Engineers, A.I. needs some help focusing, and may not be ready to roam free around millions of lines of code and not hallucinate random results. So we made Roast, which gave A.I. some structure.

In the following example I will grade a Ruby unit test.

If you don't have one already, get an OpenAPI key from [here](https://platform.openai.com/settings/organization/api-keys). You will need an account with a credit card, make sure that a basic completion works.

```bash
export OPENAI_API_KEY=sk-proj-....

curl -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_TOKEN" \
    -d '{"model":"gpt-4.1-mini","messages":[{"role":"user","content":"What is 1+1?"}]}' \
    https://api.openai.com/v1/chat/completions
```

This should produce a `chat.completion` response.

```json
{
  "id": "chatcmpl-BVdeKT88rtgxDCId9jFIpCr5sJQKv",
  "object": "chat.completion",
  "created": 1746880280,
  "model": "gpt-4.1-mini-2025-04-14",
  ...
}
```

Check out Roast. You can `gem install roast-ai` from [Rubygems](https://rubygems.org/gems/roast-ai), but I am going to reuse an example workflow, so `git clone git@github.com:Shopify/roast.git` and `cd roast`.

The [test grading workflow](https://github.com/Shopify/roast/blob/main/examples/grading/workflow.md) is a senior software engineer and testing expert that evaluates the quality of a test based on guidelines. It's configured to use `gpt-4.1-mini` to analyze coverage, but `o3`, a more expensive and capable model, to generate recommendations. The free OpenAI tier doesn't have access to these, so I have edited the file to use `gpt-4.1-mini` everywhere (`model: gpt-4.1-mini`). I also told it to use my OpenAI token from `OPENAI_API_KEY` (`api_token: $(echo $OPENAI_API_KEY)`).

```
diff --git a/examples/grading/workflow.yml b/examples/grading/workflow.yml
index d62a3d0..a10c7bc 100644
--- a/examples/grading/workflow.yml
+++ b/examples/grading/workflow.yml
@@ -1,5 +1,8 @@
 name: Grading current test changes
 
+api_token: $(echo $OPENAI_API_KEY)
+model: gpt-4.1-mini
+
 tools:
   - Roast::Tools::Grep
   - Roast::Tools::ReadFile
@@ -21,16 +24,13 @@ steps:
 
 # set non-default attributes for steps below
 analyze_coverage:
-  model: gpt-4.1-mini
   auto_loop: false
   json: true
   
 generate_grades:
-  model: o3
   json: true
 
 generate_recommendations:
-  model: o3
   auto_loop: false
   json: true
   params:
```

You may also need `shadowenv` and `rg`, so `brew install shadowenv` and `brew install rg`.

Let's run Roast on one of its own tests!

```bash
~/source/shopify/roast (main)$ ./exe/roast execute examples/grading/workflow.yml test/roast/resources_test.rb 
🔥🔥🔥 Everyone loves a good roast 🔥🔥🔥

Configuring API client with token from workflow
Starting workflow...
Workflow: roast/examples/grading/workflow.yml
Options: {}
Running workflow for file: test/roast/resources_test.rb
Executing: read_dependencies (Resource type: none)
🔍 Searching for file: resources.rb
📖 Reading file: lib/roast/resources.rb
Executing: run_coverage (Resource type: none)
Requiring step file: roast/examples/grading/run_coverage.rb
Run options: --seed 19099

# Running:

.............

Finished in 0.000992s, 13104.8373 runs/s, 16129.0306 assertions/s.

13 runs, 16 assertions, 0 failures, 0 errors, 0 skips
Executing: analyze_coverage (Resource type: none)
Executing: verify_test_helpers (Resource type: none)
Executing: verify_mocks_and_stubs (Resource type: none)
🔍 Grepping for string: def 
Executing: generate_grades (Resource type: none)
Executing: calculate_final_grade (Resource type: none)
Requiring step file: roast/examples/grading/calculate_final_grade.rb
Executing: format_result (Resource type: none)
Requiring step file: roast/examples/grading/format_result.rb
Executing: generate_recommendations (Resource type: none)
🔥🔥🔥 ROAST COMPLETE! 🔥🔥🔥
Final output saved to: roast/.roast/sessions/grading_current_test_changes/resources_test_rb_13224ed7/20250510_122040_774/final_output.txt
Final output saved to: roast/.roast/sessions/grading_current_test_changes/resources_test_rb_13224ed7/20250510_122040_774/final_output.txt
```

The test grade report is quite impressive.

```
========== TEST GRADE REPORT ==========
Test file: test/roast/resources_test.rb

FINAL GRADE:
  Score: 80/100
  Letter Grade: B 

RUBRIC SCORES:

  Line Coverage (10% of grade):

    Value: 9.0

    Score: 9/10 - "The source file has 82.93% line coverage, which is good coverage with only minor or edge case code paths remaining untested."

  Method Coverage (10% of grade):

    Value: 10.0

    Score: 10/10 - "The source file has 100% method coverage, indicating all methods are being tested."

  Branch Coverage (30% of grade):

    Value: 6.0

    Score: 6/10 - "The source file has 62.96% branch coverage, indicating some conditions lack testing for all outcomes, especially in conditional branches related to resource type detection."

  Test Helpers Usage (10% of grade):

    Value: 10.0

    Score: 10/10 - "No custom test helpers are used in the test file, so there are no issues related to helper usage."

  Mocks and Stubs Usage (10% of grade):

    Value: 10.0

    Score: 10/10 - "No mocks or stubs are used in the test file, so there are no issues related to mocking or stubbing."

  Test Readability (10% of grade):

    Value: 8.0

    Score: 8/10 - "Test names are descriptive and clearly communicate the expected behavior, though the structure could be improved with more context blocks or grouping."

  Test Maintainability (10% of grade):

    Value: 8.0

    Score: 8/10 - "Tests focus on behavior and public interfaces without coupling to implementation details, making them reasonably maintainable."

  Test Effectiveness (10% of grade):

    Value: 7.0

    Score: 7/10 - "Tests cover the main expected behaviors and resource types, but some edge cases and error conditions remain untested, as indicated by uncovered branches."
```

Using more expensive models takes a little longer to run and I get a "C" grade instead of a "B". Static analysis, such as branch coverage, gets the same score, while test effectiveness goes from 7 to 6. The better model finds untested edge cases that may cause undetected regressions. Compare _"Tests cover the main expected behaviors and resource types, but some edge cases and branches remain untested, limiting full validation of all possible inputs."_ to _"Core behaviors (file, directory, url, api, none detection) are covered, but several branches - such as command targets and glob-pattern edge cases - remain untested, leaving room for undetected regressions."_.

Honestly, wow.
