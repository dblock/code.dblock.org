---
layout: post
title: How to run GitHub Actions Locally using Act   
date: 2021-06-15
tags: [github]
comments: true
---
I'm a big fan of [GitHub Actions](https://github.com/features/actions) to automate workflows. They are declarative in nature, developed as open-source components, and execution is container-based. I also recently learned that GitHub Actions were actually not tied to GitHub infrastructure, and can be executed locally, using [act](https://github.com/nektos/act). 

Let's build OpenSearch [job-scheduler](https://github.com/opensearch-project/job-scheduler) on a local Linux.

### Download Act

Download and install act from [here](https://github.com/nektos/act#installation). I just run the `install.sh` because YOLO.

```bash
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
```

### Check Out JobScheduler

```
git checkout git@github.com:opensearch-project/job-scheduler.git
cd job-scheduler
```

### Modify Workflow (Temporary)

By default the `runner` user under which the workflow runs in the Docker container does not have write access to the current folder, therefore [the workflow](https://github.com/opensearch-project/job-scheduler/blob/main/.github/workflows/test-and-build-workflow.yml) as implemented requires one additional step. Add the following code locally in `.github/workflows/test-and-build-workflow.yml` after "Setup Java".

```yaml
- name: Chown
run: |
    sudo chown -R runner .
```

### Environment

The current workflow implementation checks out OpenSearch and builds it, thus needing a token to `git clone` from GitHub. Create a `.env` file with a read-only GitHub token.

```
GITHUB_TOKEN=valid-token
```

### Invoke Act

```
act -r --secret-file .env pull_request -P ubuntu-latest=catthehacker/ubuntu:runner-latest 
```

Act uses an open-source Docker container to run the job. Enjoy a `BUILD SUCCESSFUL` result!
