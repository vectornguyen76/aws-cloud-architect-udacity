# Data Durability and Recovery

In this project, I will create highly available solutions to common use cases. I will build a Multi-Availability Zone, Multi-Region database and demonstrate how to use it in multiple geographically separate AWS regions. Additionally, I will create a website hosting solution that is versioned to quickly and easily undo any data destruction and accidents.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Project Instructions](#project-instructions)
   - [CloudFormation](#cloudformation)
   - [Part 1: Data Durability and Recovery](#part-1-data-durability-and-recovery)
     - [Highly Durable RDS Database](#highly-durable-rds-database)
     - [Estimate Availability of Configuration](#estimate-availability-of-configuration)
     - [Demonstrate Normal Usage](#demonstrate-normal-usage)
     - [Monitor Database](#monitor-database)
   - [Part 2: Failover and Recovery](#part-2-failover-and-recovery)
   - [Part 3: Website Resiliency](#part-3-website-resiliency)
3. [Architecture Diagram](#architecture-diagram)

## Getting Started

To get started, I will clone this repo. Aside from instructions, it contains a CloudFormation script to build an AWS VPC with public and private subnets. It also contains an example website that I will host in an AWS S3 bucket in my account.

```
├── README.md
├── cloudformation
│   └── vpc.yaml
├── s3
│   ├── fall.jpg
│   ├── index.html
│   ├── spring.jpg
│   ├── summer.jpg
│   └── winter.jpg
└── screenshots
    ├── cloudformationCreate.png
    ├── primary_Vpc.png
    ├── secondary_Vpc.png
    ├── primaryDB_config.png
    ├── secondaryDB_config.png
    ├── primaryDB_subnetgroup.png
    ├── secondaryDB_subnetgroup.png
    ├── primaryVPC_subnets.png
    ├── secondaryVPC_subnets.png
    ├── primary_subnet_routing.png
    ├── secondary_subnet_routing.png
    ├── monitoring_connections.png
    ├── monitoring_replication.png
    ├── rr_before_promotion.png
    ├── rr_after_promotion.png
    ├── s3_original.png
    ├── s3_season.png
    ├── s3_season_revert.png
    ├── s3_deletion.png
    └── s3_delete_marker.png
```

## Project Instructions

### CloudFormation

In this project, I will use AWS CloudFormation to create Virtual Private Clouds (VPCs). CloudFormation is an AWS service that allows me to create infrastructure as code. Here is the complete list of resources the YAML CloudFormation template will create for me:

- VPC
- Two private subnets
- Two public subnets
- Route tables for public and private subnets, and associate the route tables with the subnets
- Two security groups, one for the application and another for the database
- An Internet Gateway

The diagram below displays the overall architecture when I am done creating the VPC in two regions separately. The diagram assumes I will use `us-east-1` as Primary and `us-west-2` as Secondary (failover) region.

![Architecture](./assets/architecture.jpeg)

To build a VPC from the YAML file, I will follow these steps:

1. Go to AWS Services -> CloudFormation
2. Create stack “With new resources (standard)”
   ![Create VPC](./screenshots/cloudformationCreate.png)
3. Select "Template is ready"
4. Upload a template file
5. Click “Choose file” button and select the provided YAML file
6. Click "Next"
7. Fill in the Stack name, e.g., `cd1908-project-stack` for the Primary and `cd1908-project-stack-secondary` for the Secondary stack
8. Name the VPCs as "Primary" and "Secondary" respectively
9. Update the CIDR blocks to match the architecture diagram above (only needed for the secondary region)
10. Click "Next"
11. Click "Next" again
12. Click "Create stack"
13. Wait for the stack to build out and refresh until the status becomes “CREATE_COMPLETE”
14. Observe the “Outputs” tab for the created IDs which will be used later

### Part 1: Data Durability and Recovery

To achieve high levels of durability and availability in AWS, I will take advantage of multiple AWS regions.

1. Pick two AWS regions: an active region and a standby region.
2. Use CloudFormation to create one VPC in each region. Name the VPC in the active region "Primary" and in the standby region "Secondary".

**Note**: I need to use different CIDR address ranges for the VPCs.

I will save screenshots of both VPCs after creation:

- ![Primary VPC](./screenshots/primary_Vpc.png)
- ![Secondary VPC](./screenshots/secondary_Vpc.png)

#### Highly Durable RDS Database

1. Create a new RDS Subnet group in both the active and standby regions.
2. Create a new MySQL, multi-AZ database in the active region with the following configurations:
   - Use a “burstable” instance class
   - Attach only the “UDARR-Database” security group
   - Create an initial database named “udacity”
3. Create a read replica database in the standby region with the same configurations as the database in the active region.

I will save screenshots of the configurations:

- ![Primary DB Config](./screenshots/primaryDB_config.png)
- ![Secondary DB Config](./screenshots/secondaryDB_config.png)
- ![Primary DB Subnet Group](./screenshots/primaryDB_subnetgroup.png)
- ![Secondary DB Subnet Group](./screenshots/secondaryDB_subnetgroup.png)
- ![Primary VPC Subnets](./screenshots/primaryVPC_subnets.png)
- ![Secondary VPC Subnets](./screenshots/secondaryVPC_subnets.png)
- ![Primary Subnet Routing](./screenshots/primary_subnet_routing.png)
- ![Secondary Subnet Routing](./screenshots/secondary_subnet_routing.png)

#### Estimating Availability

I will estimate the achievable Recovery Time Objective (RTO) and Recovery Point Objective (RPO) for this Multi-AZ, multi-region database in terms of:

1. Minimum RTO for a single AZ outage
2. Minimum RTO for a single region outage
3. Minimum RPO for a single AZ outage
4. Minimum RPO for a single region outage

I will save my answers in a text file named `estimates.txt`.

#### Demonstrate Normal Usage

In the active region:

1. I will create an EC2 key pair in the region.
2. I will launch an Amazon Linux EC2 instance in the active region, configuring it to use the VPC's public subnet and security group ("UDARR-Application").
3. I will SSH to the instance and connect to the "udacity" database in the RDS instance.
4. I will verify that I can create a table, insert data, and read data from the database.

I will save the log of these operations in a text file called `log_primary.txt`.

#### Monitoring

1. I will observe the “DB Connections” to the database and how this metric changes as I connect to the database.
2. I will observe the “Replication” configuration with my multi-region read replica.

I will save screenshots of the monitoring:

- ![DB Connections](./screenshots/monitoring_connections.png)
- ![Monitoring Replication](./screenshots/monitoring_replication.png)

### Part 2: Failover and Recovery

In the standby region:

1. I will create an EC2 key pair in the region.
2. I will launch an Amazon Linux EC2 instance in the standby region, configuring it to use the VPC's public subnet and security group ("UDARR-Application").
3. I will SSH to the instance and connect to the read replica database.
4. I will verify that I cannot insert data into the database but can read from it.

I will save the log of these operations in a text file called `log_rr_before_promotion.txt`.

I will save a screenshot of the database configuration before promotion:

- ![Before Promotion](./screenshots/rr_before_promotion.png)

5. I will promote the read replica.
6. I will verify that I can insert data into and read from the promoted database in the standby region.

I will save the log of these operations in a text file named `log_rr_after_promotion.txt`.

I will save a screenshot of the database configuration after promotion:

- ![After Promotion](./screenshots/rr_after_promotion.png)

### Part 3: Website Resiliency

I will create a resilient static web hosting solution in AWS. I will create a versioned S3 bucket and configure it as a static website.

1. I will enter “index.html” for both Index document and Error document.
2. I will upload the files from the GitHub repo (`/project/s3/`).
3. I will paste the URL into a web browser to see my website.

I will save a screenshot of the webpage:

- ![Original Website](./screenshots/s3_original.png)

**Accidental Changes and Recovery**

1. I will change `index.html` to refer to a different “season”.
2. I will re-upload `index.html` and refresh the webpage.

I will save a screenshot of the modified webpage:

- ![Modified Website](./screenshots/s3_season.png)

I will recover the website by rolling back to the previous version.

1. I will recover the `index.html` object back to the original version.
2. I will refresh the webpage.

I will save a screenshot of the reverted webpage:

- ![Reverted Website](./screenshots/s3_season_revert.png)

**Accidental Deletion and Recovery**

1. I will delete “winter.jpg”.

I will save screenshots of the modified webpage and the existing versions of the file showing the "Deletion marker":

- ![S3 Deletion](./screenshots/s3_deletion.png)
- ![S3 Deletion Marker](./screenshots/s3_delete_marker.png)

I will recover the deleted object.

1. I will recover the deleted object.
2. I will refresh the webpage.

I will save a screenshot of the recovered webpage:

- ![Recovered Website](./screenshots/s3_delete_revert.png)
