---
layout: post
title: Using Claude Code with Google Sheets
date: 2025-07-30 01:00:00
tags: [ai, tools, claude]
comments: true
---
Let's get [Claude Code](https://www.anthropic.com/claude-code) to connect to Google Sheets. We'll use [this Google Sample Spreadsheet](https://docs.google.com/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/edit?gid=0#gid=0).

Go to the [Google Cloud Console](https://console.cloud.google.com/), create a new project, and enable the Google Sheets API on it.

<img src="{{ site.url }}/images/posts/2025/2025-07-30-using-claude-code-with-google-sheets/new-gcloud-project.gif" />

Install the [Google Cloud CLI](https://cloud.google.com/sdk/docs/install-sdk).

```bash
brew install google-cloud-sdk
```

Choose the newly created project on the command line.

```bash
~$ gcloud config set project gsheetscli

Updated property [core/project].
```

Login again, but this time enable Google Drive access.

```bash
gcloud auth login --enable-gdrive-access
```

You can now access the spreadsheet with `curl`.

```bash
curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  "https://sheets.googleapis.com/v4/spreadsheets/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/values/Class%20Data"
```

```json
{
  "range": "'Class Data'!A1:V101",
  "majorDimension": "ROWS",
  "values": [
    [
      "Student Name",
      "Gender",
      "Class Level",
      "Home State",
      "Major",
      "Extracurricular Activity"
    ],
    ...
  ]
}
```

Let's ask Claude to do something useful.

Let's ask Claude to do something useful.

```
~$ claude

╭───────────────────────────────────────────────────╮
│ ✻ Welcome to Claude Code!                         │
╰───────────────────────────────────────────────────╯

> analyze the distribution of extracurricular activities in https://docs.google.com/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/edit?gid=0#gid=0

⏺ I'll analyze the distribution of extracurricular activities from the Google Sheets document you provided.

⏺ Fetch(https://docs.google.com/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/edit?gid=0#gid=0)
  ⎿  Received 193.5KB (200 OK)

⏺ The extracurricular activities distribution shows perfect balance:

  Activity Distribution:
  - Drama Club: 5 students (16.7%)
  - Basketball: 5 students (16.7%)
  - Debate: 5 students (16.7%)
  - Lacrosse: 5 students (16.7%)
  - Baseball: 5 students (16.7%)
  - Track & Field: 5 students (16.7%)

  Total: 30 students across 6 activities

  Each activity has exactly 5 students participating, resulting in an even distribution with no activity being more popular than others in this dataset.
```

Whoa.

### Troubleshooting

You need to `gcloud auth login`, otherwise you get a "Method doesn't allow unregistered callers" error.

```bash
curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  "https://sheets.googleapis.com/v4/spreadsheets/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/values/Class%20Data"
```

```json
{
  "error": {
    "code": 403,
    "message": "Method doesn't allow unregistered callers (callers without established identity). Please use API Key or other form of API consumer identity to call this API.",
    "status": "PERMISSION_DENIED"
  }
}
```

You need a project that has access to Google Sheets. Otherwise you get a "Request had insufficient authentication scopes." error.

```json
{
  "error": {
    "code": 403,
    "message": "Request had insufficient authentication scopes.",
    "status": "PERMISSION_DENIED",
    "details": [
      {
        "@type": "type.googleapis.com/google.rpc.ErrorInfo",
        "reason": "ACCESS_TOKEN_SCOPE_INSUFFICIENT",
        "domain": "googleapis.com",
        "metadata": {
          "method": "google.apps.sheets.v4.SpreadsheetsService.GetValues",
          "service": "sheets.googleapis.com"
        }
      }
    ]
  }
}
```

Select the project with `gcloud config set project [name]`, enable access to Google Sheets with `gcloud services enable sheets.googleapis.com` and login again with `gcloud auth login --enable-gdrive-access`.
