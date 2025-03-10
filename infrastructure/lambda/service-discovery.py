import os
from typing import TYPE_CHECKING, TypedDict

import boto3
from botocore.exceptions import ClientError

if TYPE_CHECKING:
    from mypy_boto3_ec2.client import EC2Client
    from mypy_boto3_route53.client import Route53Client
    from mypy_boto3_route53.literals import ChangeActionType
    from mypy_boto3_ecs.type_defs import TaskTypeDef


client_ec2: 'EC2Client' = boto3.client('ec2')
client_route53: 'Route53Client' = boto3.client('route53')

# Manages creation and deletion of multivalue A records for an ECS service to load-balance via DNS.
# Necessary because AWS Cloud Map only handles DNS-based service discovery with private IPs.
# Doesn't handle cases with more than 300 records.

# This is NOT suitable for production systems yet - it needs to ensure that tasks are put into DNS only
# when they're passing their health checks.

# Expected env config:
# HOSTED_ZONE_ID: ID of hosted zone to put our records in
# ROOT_DOMAIN: Root domain name of target hosted zone. Don't feel like looking this up automatically.
# TARGET_SUBDOMAIN: Subdomain to create records under.

ENI_STATUSES_WE_DONT_CARE_ABOUT = ['PRECREATED', 'DELETED']


class ECSEvent(TypedDict):
    detail: 'TaskTypeDef'


def get_eni_ip(task_info: 'TaskTypeDef') -> str | None:
    if 'attachments' not in task_info:
        return None
    try:
        eni_attachment = next(
            attachment
            for attachment
            in task_info['attachments']
            if attachment['type'] == 'eni' and attachment['status'] not in ENI_STATUSES_WE_DONT_CARE_ABOUT
        )
    except StopIteration:
        print("No non-precreated ENI attached to this task. Nothing to do.")
        return None

    try:
        eni_id = next(
            detail
            for detail
            in eni_attachment['details']
            if detail['name'] == 'networkInterfaceId'
        )['value']
    except StopIteration:
        print(task_info)
        raise RuntimeError("No network interface ID listed for this ENI somehow.")

    try:
        enis = client_ec2.describe_network_interfaces(NetworkInterfaceIds=[eni_id])['NetworkInterfaces']

        if len(enis) == 0:
            print("No ENIs matching returned ID found.")
            print("This probably means the ENI has already been disconnected or is yet to be connected.")
            print("Another run of this function will resolve this.")
            return None

        eni = enis[0]
        if 'Association' in eni:
            if 'PublicIp' in eni['Association']:
                return eni['Association']['PublicIp']

        return None
    except ClientError:
        print("Network interface doesn't exist. That's ")
        print("This probably means the ENI has already been disconnected or is yet to be connected.")
        print("Another run of this function will resolve this.")
        return None


def update_record_set(task_arn: str, ip: str, action: 'ChangeActionType'):
    try:
        _ = client_route53.change_resource_record_sets(
            HostedZoneId=os.environ['HOSTED_ZONE_ID'],
            ChangeBatch={
                'Changes': [
                    {
                        'Action': action,
                        'ResourceRecordSet': {
                            'Name': f"{os.environ['TARGET_SUBDOMAIN']}.{os.environ['ROOT_DOMAIN']}",
                            'Type': 'A',
                            'MultiValueAnswer': True,
                            'TTL': 60,
                            'ResourceRecords': [{'Value': ip}],
                            'SetIdentifier': task_arn,
                        },
                    },
                ],
            },
        )
    except client_route53.exceptions.InvalidChangeBatch:
        # Failing to delete something because it doesn't exist is fine.
        if action != 'DELETE':
            raise


# Event shape: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_cwe_events.html#ecs_task_events
def lambda_handler(event: 'ECSEvent', _context):
    eni_ip = get_eni_ip(event['detail'])
    if eni_ip is None:
        print("No ENI on this task, nothing to do.")
        return

    task_arn = event['detail']['taskArn']

    if event['detail']['desiredStatus'] == "RUNNING":
        update_record_set(task_arn, eni_ip, 'UPSERT')
    elif event['detail']['desiredStatus'] == "STOPPED":
        update_record_set(task_arn, eni_ip, 'DELETE')
