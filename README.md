# learn-projects

The code for the tutorials on [learn.breqwatr.cloud](https://learn.breqwatr.workers.dev/tutorials/), the Breqwatr Cloud training course. Every file here is the code a tutorial page shows, and every release was run end to end on Breqwatr Cloud before it was tagged.

| Tutorial | Page | Code |
| --- | --- | --- |
| 4.1 | [Launch your first instances](https://learn.breqwatr.workers.dev/tutorials/first-instance/) | [`first-instance/`](first-instance/) |
| 4.2 | [OpenTofu fundamentals](https://learn.breqwatr.workers.dev/tutorials/opentofu-fundamentals/) | [`opentofu-fundamentals/`](opentofu-fundamentals/) |
| 4.3 | [Configuration with Ansible](https://learn.breqwatr.workers.dev/tutorials/ansible-configuration/) | [`ansible-configuration/`](ansible-configuration/) |
| 4.4 | [A three-tier web app](https://learn.breqwatr.workers.dev/tutorials/three-tier-web-app/) | [`three-tier-web-app/`](three-tier-web-app/) |
| 4.5 | [Rebuild, don't repair](https://learn.breqwatr.workers.dev/tutorials/rebuild-dont-repair/) | [`rebuild-dont-repair/`](rebuild-dont-repair/) |
| 4.6 | [Object storage with S3 tooling](https://learn.breqwatr.workers.dev/tutorials/object-storage-s3/) | [`object-storage-s3/`](object-storage-s3/) |
| 4.7 | [Kubernetes on BKS](https://learn.breqwatr.workers.dev/tutorials/kubernetes-on-bks/) | [`kubernetes-on-bks/`](kubernetes-on-bks/) |
| 4.8 | [Build your own pipeline platform](https://learn.breqwatr.workers.dev/tutorials/pipeline-platform/) | [`pipeline-platform/`](pipeline-platform/) |
| 4.9 | [Deploy from the pipeline](https://learn.breqwatr.workers.dev/tutorials/deploy-from-pipeline/) | [`deploy-from-pipeline/`](deploy-from-pipeline/) |

## Using it

Each folder stands on its own. Follow its tutorial page, which explains every file and the order to run things in. To get the code a page shows, use the release tag the page links to:

```bash
git clone --branch <tag> https://github.com/breqwatr/learn-projects.git
```

Files with your own values in them (`terraform.tfvars`, `vars.yml`, keys and vault files) stay on your computer and out of version control. Where a folder needs them, it has an example to copy or placeholders such as `<your-ip>` to replace.

## Versions

| Tool | Version |
| --- | --- |
| OpenTofu | 1.13.1 |
| OpenStack provider | 3.4.0, pinned as `~> 3.4` |
| random provider | 3.9.1 |
| Ansible | 14.5.0 (ansible-core 2.21.5), on Python 3.14 |

Each OpenTofu folder commits its `.terraform.lock.hcl`, with provider hashes for Linux, macOS and Windows, so `tofu init` installs the providers that were tested.

## Releases

Releases are tagged `vMAJOR.MINOR.PATCH`. A major release renames or moves folders or files, a minor release adds a tutorial or moves to new tool versions, and a patch release fixes code. A tag is cut only after every changed folder has passed a full run on Breqwatr Cloud.

## Issues and pull requests

Issues are welcome: open one if a folder doesn't work as its page describes. Pull requests aren't accepted for now.

## Licence

MIT. See [LICENSE](LICENSE).
