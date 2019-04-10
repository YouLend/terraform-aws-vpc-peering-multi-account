<!-- This file was automatically generated by the `build-harness`. Make all changes to `README.yaml` and run `make readme` to rebuild this file. -->
[![README Header][readme_header_img]][readme_header_link]

[![Cloud Posse][logo]](https://cpco.io/homepage)

# terraform-aws-vpc-peering-multi-account

 [![Build Status](https://travis-ci.org/cloudposse/terraform-aws-vpc-peering-multi-account.svg?branch=master)](https://travis-ci.org/cloudposse/terraform-aws-vpc-peering-multi-account) [![Latest Release](https://img.shields.io/github/release/cloudposse/terraform-aws-vpc-peering-multi-account.svg)](https://github.com/cloudposse/terraform-aws-vpc-peering-multi-account/releases/latest) [![Slack Community](https://slack.cloudposse.com/badge.svg)](https://slack.cloudposse.com)


Terraform module to create a peering connection between any two VPCs existing in different AWS accounts.

This module supports performing this action from a 3rd account (e.g. a "root" account) by specifying the roles to assume for each member account.

**IMPORTANT:** AWS allows a multi-account VPC Peering Connection to be deleted from either the requester's or accepter's side. However, Terraform only allows the VPC Peering Connection to be deleted from the requester's side by removing the corresponding `aws_vpc_peering_connection` resource from your configuration. [Read more about this](https://www.terraform.io/docs/providers/aws/r/vpc_peering_accepter.html) on Terraform's documentation portal.


---

This project is part of our comprehensive ["SweetOps"](https://cpco.io/sweetops) approach towards DevOps. 
[<img align="right" title="Share via Email" src="https://docs.cloudposse.com/images/ionicons/ios-email-outline-2.0.1-16x16-999999.svg"/>][share_email]
[<img align="right" title="Share on Google+" src="https://docs.cloudposse.com/images/ionicons/social-googleplus-outline-2.0.1-16x16-999999.svg" />][share_googleplus]
[<img align="right" title="Share on Facebook" src="https://docs.cloudposse.com/images/ionicons/social-facebook-outline-2.0.1-16x16-999999.svg" />][share_facebook]
[<img align="right" title="Share on Reddit" src="https://docs.cloudposse.com/images/ionicons/social-reddit-outline-2.0.1-16x16-999999.svg" />][share_reddit]
[<img align="right" title="Share on LinkedIn" src="https://docs.cloudposse.com/images/ionicons/social-linkedin-outline-2.0.1-16x16-999999.svg" />][share_linkedin]
[<img align="right" title="Share on Twitter" src="https://docs.cloudposse.com/images/ionicons/social-twitter-outline-2.0.1-16x16-999999.svg" />][share_twitter]


[![Terraform Open Source Modules](https://docs.cloudposse.com/images/terraform-open-source-modules.svg)][terraform_modules]



It's 100% Open Source and licensed under the [APACHE2](LICENSE).







We literally have [*hundreds of terraform modules*][terraform_modules] that are Open Source and well-maintained. Check them out! 





## Screenshots


![vpc-peering](images/vpc-peering.png)
*VPC Peering Connection in the AWS Web Console*



## Usage


**IMPORTANT:** Do not pin to `master` because there may be breaking changes between releases. Instead pin to the release tag (e.g. `?ref=tags/x.y.z`) of one of our [latest releases](https://github.com/cloudposse/terraform-aws-vpc-peering-multi-account/releases).

For a complete example, see [examples/complete](examples/complete)

```hcl
module "vpc_peering_cross_account" {
  source           = "git::https://github.com/cloudposse/terraform-aws-vpc-peering-multi-account.git?ref=master"
  namespace        = "eg"
  stage            = "dev"
  name             = "cluster"

  requester_aws_assume_role_arn             = "arn:aws:iam::XXXXXXXX:role/cross-account-vpc-peering-test"
  requester_region                          = "us-west-2"
  requester_vpc_id                          = "vpc-xxxxxxxx"
  requester_allow_remote_vpc_dns_resolution = "true"

  accepter_aws_assume_role_arn             = "arn:aws:iam::YYYYYYYY:role/cross-account-vpc-peering-test"
  accepter_region                          = "us-east-1"
  accepter_vpc_id                          = "vpc-yyyyyyyy"
  accepter_allow_remote_vpc_dns_resolution = "true"
}
```

The `arn:aws:iam::XXXXXXXX:role/cross-account-vpc-peering-test` requester IAM Role should have the following Trust Policy:

<details><summary>Show Trust Policy</summary>

```js
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::XXXXXXXX:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {}
    }
  ]
}
```

</details>
<br/>

and the following IAM Policy attached to it:

__NOTE:__ the policy specifies the permissions to create (with `terraform plan/apply`) and delete (with `terraform destroy`) all the required resources in the requester AWS account

<details><summary>Show IAM Policy</summary>

```js
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateRoute",
        "ec2:DeleteRoute"
      ],
      "Resource": "arn:aws:ec2:*:XXXXXXXX:route-table/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeVpcPeeringConnections",
        "ec2:DescribeVpcs",
        "ec2:ModifyVpcPeeringConnectionOptions",
        "ec2:DescribeSubnets",
        "ec2:DescribeVpcAttribute",
        "ec2:DescribeRouteTables"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AcceptVpcPeeringConnection",
        "ec2:DeleteVpcPeeringConnection",
        "ec2:CreateVpcPeeringConnection",
        "ec2:RejectVpcPeeringConnection"
      ],
      "Resource": [
        "arn:aws:ec2:*:XXXXXXXX:vpc-peering-connection/*",
        "arn:aws:ec2:*:XXXXXXXX:vpc/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DeleteTags",
        "ec2:CreateTags"
      ],
      "Resource": "arn:aws:ec2:*:XXXXXXXX:vpc-peering-connection/*"
    }
  ]
}
```

</details>

where `XXXXXXXX` is the requester AWS account ID.

<br/>

The `arn:aws:iam::YYYYYYYY:role/cross-account-vpc-peering-test` accepter IAM Role should have the following Trust Policy:

<details><summary>Show Trust Policy</summary>

```js
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::XXXXXXXX:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {}
    }
  ]
}
```

</details>

__NOTE__: The accepter Trust Policy is the same as the requester Trust Policy since it defines who can assume the IAM Role.
In the requester case, the requester account ID itself is the trusted entity.
For the accepter, the Trust Policy specifies that the requester account ID `XXXXXXXX` can assume the role in the accepter AWS account `YYYYYYYY`.

and the following IAM Policy attached to it:

__NOTE:__ the policy specifies the permissions to create (with `terraform plan/apply`) and delete (with `terraform destroy`) all the required resources in the accepter AWS account

<details><summary>Show IAM Policy</summary>

```js
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateRoute",
        "ec2:DeleteRoute"
      ],
      "Resource": "arn:aws:ec2:*:YYYYYYYY:route-table/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeVpcPeeringConnections",
        "ec2:DescribeVpcs",
        "ec2:ModifyVpcPeeringConnectionOptions",
        "ec2:DescribeSubnets",
        "ec2:DescribeVpcAttribute",
        "ec2:DescribeRouteTables"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AcceptVpcPeeringConnection",
        "ec2:DeleteVpcPeeringConnection",
        "ec2:CreateVpcPeeringConnection",
        "ec2:RejectVpcPeeringConnection"
      ],
      "Resource": [
        "arn:aws:ec2:*:YYYYYYYY:vpc-peering-connection/*",
        "arn:aws:ec2:*:YYYYYYYY:vpc/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DeleteTags",
        "ec2:CreateTags"
      ],
      "Resource": "arn:aws:ec2:*:YYYYYYYY:vpc-peering-connection/*"
    }
  ]
}
```

</details>

where `YYYYYYYY` is the accepter AWS account ID.

For more information on IAM policies and permissions for VPC peering, see [Creating and managing VPC peering connections](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_IAM.html#vpcpeeringiam).






## Makefile Targets
```
Available targets:

  help                                Help screen
  help/all                            Display help for all targets
  help/short                          This help short screen
  lint                                Lint terraform code

```
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| accepter_allow_remote_vpc_dns_resolution | Allow accepter VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the requester VPC | string | `true` | no |
| accepter_aws_assume_role_arn | Accepter AWS Assume Role ARN | string | - | yes |
| accepter_region | Accepter AWS region | string | - | yes |
| accepter_vpc_id | Accepter VPC ID filter | string | `` | no |
| accepter_vpc_tags | Accepter VPC Tags filter | map | `<map>` | no |
| attributes | Additional attributes (e.g. `a` or `b`) | list | `<list>` | no |
| auto_accept | Automatically accept the peering | string | `true` | no |
| delimiter | Delimiter to be used between `namespace`, `stage`, `name`, and `attributes` | string | `-` | no |
| enabled | Set to false to prevent the module from creating or accessing any resources | string | `true` | no |
| name | Name  (e.g. `app` or `cluster`) | string | - | yes |
| namespace | Namespace (e.g. `eg` or `cp`) | string | - | yes |
| requester_allow_remote_vpc_dns_resolution | Allow requester VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the accepter VPC | string | `true` | no |
| requester_aws_assume_role_arn | Requester AWS Assume Role ARN | string | - | yes |
| requester_region | Requester AWS region | string | - | yes |
| requester_vpc_id | Requester VPC ID filter | string | `` | no |
| requester_vpc_tags | Requester VPC Tags filter | map | `<map>` | no |
| stage | Stage (e.g. `prod`, `dev`, `staging`) | string | - | yes |
| tags | Additional tags (e.g. `{"BusinessUnit" = "XYZ"`) | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| accepter_accept_status | Accepter VPC peering connection request status |
| accepter_connection_id | Accepter VPC peering connection ID |
| requester_accept_status | Requester VPC peering connection request status |
| requester_connection_id | Requester VPC peering connection ID |




## Share the Love 

Like this project? Please give it a ★ on [our GitHub](https://github.com/cloudposse/terraform-aws-vpc-peering-multi-account)! (it helps us **a lot**) 

Are you using this project or any of our other projects? Consider [leaving a testimonial][testimonial]. =)


## Related Projects

Check out these related projects.

- [terraform-aws-vpc](https://github.com/cloudposse/terraform-aws-vpc) - Terraform Module that defines a VPC with public/private subnets across multiple AZs with Internet Gateways
- [terraform-aws-vpc-peering](https://github.com/cloudposse/terraform-aws-vpc) - Terraform module to create a peering connection between two VPCs in the same AWS account
- [terraform-aws-kops-vpc-peering](https://github.com/cloudposse/terraform-aws-kops-vpc-peering) - Terraform module to create a peering connection between a backing services VPC and a VPC created by Kops




## References

For additional context, refer to some of these links. 

- [What is VPC Peering?](https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html) - VPC peering connection is a networking connection between two VPCs that enables you to route traffic between them using private IPv4 addresses or IPv6 addresses.


## Help

**Got a question?**

File a GitHub [issue](https://github.com/cloudposse/terraform-aws-vpc-peering-multi-account/issues), send us an [email][email] or join our [Slack Community][slack].

[![README Commercial Support][readme_commercial_support_img]][readme_commercial_support_link]

## Commercial Support

Work directly with our team of DevOps experts via email, slack, and video conferencing. 

We provide [*commercial support*][commercial_support] for all of our [Open Source][github] projects. As a *Dedicated Support* customer, you have access to our team of subject matter experts at a fraction of the cost of a full-time engineer. 

[![E-Mail](https://img.shields.io/badge/email-hello@cloudposse.com-blue.svg)][email]

- **Questions.** We'll use a Shared Slack channel between your team and ours.
- **Troubleshooting.** We'll help you triage why things aren't working.
- **Code Reviews.** We'll review your Pull Requests and provide constructive feedback.
- **Bug Fixes.** We'll rapidly work to fix any bugs in our projects.
- **Build New Terraform Modules.** We'll [develop original modules][module_development] to provision infrastructure.
- **Cloud Architecture.** We'll assist with your cloud strategy and design.
- **Implementation.** We'll provide hands-on support to implement our reference architectures. 



## Terraform Module Development

Are you interested in custom Terraform module development? Submit your inquiry using [our form][module_development] today and we'll get back to you ASAP.


## Slack Community

Join our [Open Source Community][slack] on Slack. It's **FREE** for everyone! Our "SweetOps" community is where you get to talk with others who share a similar vision for how to rollout and manage infrastructure. This is the best place to talk shop, ask questions, solicit feedback, and work together as a community to build totally *sweet* infrastructure.

## Newsletter

Signup for [our newsletter][newsletter] that covers everything on our technology radar.  Receive updates on what we're up to on GitHub as well as awesome new projects we discover. 

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/cloudposse/terraform-aws-vpc-peering-multi-account/issues) to report any bugs or file feature requests.

### Developing

If you are interested in being a contributor and want to get involved in developing this project or [help out](https://cpco.io/help-out) with our other projects, we would love to hear from you! Shoot us an [email][email].

In general, PRs are welcome. We follow the typical "fork-and-pull" Git workflow.

 1. **Fork** the repo on GitHub
 2. **Clone** the project to your own machine
 3. **Commit** changes to your own branch
 4. **Push** your work back up to your fork
 5. Submit a **Pull Request** so that we can review your changes

**NOTE:** Be sure to merge the latest changes from "upstream" before making a pull request!


## Copyright

Copyright © 2017-2019 [Cloud Posse, LLC](https://cpco.io/copyright)



## License 

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) 

See [LICENSE](LICENSE) for full details.

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.









## Trademarks

All other trademarks referenced herein are the property of their respective owners.

## About

This project is maintained and funded by [Cloud Posse, LLC][website]. Like it? Please let us know by [leaving a testimonial][testimonial]!

[![Cloud Posse][logo]][website]

We're a [DevOps Professional Services][hire] company based in Los Angeles, CA. We ❤️  [Open Source Software][we_love_open_source].

We offer [paid support][commercial_support] on all of our projects.  

Check out [our other projects][github], [follow us on twitter][twitter], [apply for a job][jobs], or [hire us][hire] to help with your cloud strategy and implementation.



### Contributors

|  [![Andriy Knysh][aknysh_avatar]][aknysh_homepage]<br/>[Andriy Knysh][aknysh_homepage] | [![Erik Osterman][osterman_avatar]][osterman_homepage]<br/>[Erik Osterman][osterman_homepage] |
|---|---|

  [aknysh_homepage]: https://github.com/aknysh
  [aknysh_avatar]: https://github.com/aknysh.png?size=150
  [osterman_homepage]: https://github.com/osterman
  [osterman_avatar]: https://github.com/osterman.png?size=150



[![README Footer][readme_footer_img]][readme_footer_link]
[![Beacon][beacon]][website]

  [logo]: https://cloudposse.com/logo-300x69.svg
  [docs]: https://cpco.io/docs
  [website]: https://cpco.io/homepage
  [github]: https://cpco.io/github
  [jobs]: https://cpco.io/jobs
  [hire]: https://cpco.io/hire
  [slack]: https://cpco.io/slack
  [linkedin]: https://cpco.io/linkedin
  [twitter]: https://cpco.io/twitter
  [testimonial]: https://cpco.io/leave-testimonial
  [newsletter]: https://cpco.io/newsletter
  [email]: https://cpco.io/email
  [commercial_support]: https://cpco.io/commercial-support
  [we_love_open_source]: https://cpco.io/we-love-open-source
  [module_development]: https://cpco.io/module-development
  [terraform_modules]: https://cpco.io/terraform-modules
  [readme_header_img]: https://cloudposse.com/readme/header/img?repo=cloudposse/terraform-aws-vpc-peering-multi-account
  [readme_header_link]: https://cloudposse.com/readme/header/link?repo=cloudposse/terraform-aws-vpc-peering-multi-account
  [readme_footer_img]: https://cloudposse.com/readme/footer/img?repo=cloudposse/terraform-aws-vpc-peering-multi-account
  [readme_footer_link]: https://cloudposse.com/readme/footer/link?repo=cloudposse/terraform-aws-vpc-peering-multi-account
  [readme_commercial_support_img]: https://cloudposse.com/readme/commercial-support/img?repo=cloudposse/terraform-aws-vpc-peering-multi-account
  [readme_commercial_support_link]: https://cloudposse.com/readme/commercial-support/link?repo=cloudposse/terraform-aws-vpc-peering-multi-account
  [share_twitter]: https://twitter.com/intent/tweet/?text=terraform-aws-vpc-peering-multi-account&url=https://github.com/cloudposse/terraform-aws-vpc-peering-multi-account
  [share_linkedin]: https://www.linkedin.com/shareArticle?mini=true&title=terraform-aws-vpc-peering-multi-account&url=https://github.com/cloudposse/terraform-aws-vpc-peering-multi-account
  [share_reddit]: https://reddit.com/submit/?url=https://github.com/cloudposse/terraform-aws-vpc-peering-multi-account
  [share_facebook]: https://facebook.com/sharer/sharer.php?u=https://github.com/cloudposse/terraform-aws-vpc-peering-multi-account
  [share_googleplus]: https://plus.google.com/share?url=https://github.com/cloudposse/terraform-aws-vpc-peering-multi-account
  [share_email]: mailto:?subject=terraform-aws-vpc-peering-multi-account&body=https://github.com/cloudposse/terraform-aws-vpc-peering-multi-account
  [beacon]: https://ga-beacon.cloudposse.com/UA-76589703-4/cloudposse/terraform-aws-vpc-peering-multi-account?pixel&cs=github&cm=readme&an=terraform-aws-vpc-peering-multi-account